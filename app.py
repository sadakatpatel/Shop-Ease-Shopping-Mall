from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash
from werkzeug.security import generate_password_hash, check_password_hash
from database import get_db, init_db
from decimal import Decimal

app = Flask(__name__)
app.secret_key = 'change-this-secret-key'

CLOTHING_CATEGORIES = (
    "Men's Clothing",
    "Women's Clothing",
    "Baby Clothing",
    "Kids' Clothing",
    "Teen Clothing",
    "Ethnic Wear",
    "Korean Fashion",
    "Western Wear",
    "Streetwear"
)
_CLOTHING_CATEGORY_SQL = ','.join(['%s'] * len(CLOTHING_CATEGORIES))
_PRODUCT_FAMILIES = (
    ('Jeans', ('jeans',)),
    ('T-shirts', ('t-shirt', 't shirt', 'tee')),
    ('Shirts', ('shirt',)),
    ('Dresses', ('dress',)),
    ('Hoodies', ('hoodie',)),
    ('Baby outfits', ('onesie', 'romper', 'sleepsuit')),
    ('Ethnic wear', ('kurti', 'kurta', 'suit set')),
    ('Trousers and joggers', ('trouser', 'jogger')),
    ('Layering clothes', ('jacket', 'cardigan')),
    ('Tops', ('top',)),
    ('Skirts', ('skirt',)),
    ('Cardigans and knitwear', ('cardigan', 'knit', 'sweater')),
    ('Cargo pants', ('cargo',)),
)


def product_family(product_name):
    name = product_name.casefold()
    for family, keywords in _PRODUCT_FAMILIES:
        if any(keyword in name for keyword in keywords):
            return family
    return None


def search_catalog(cur, query, category=None, limit=12):
    like = f"%{query}%"
    category_filter = " AND category=%s" if category else ""
    category_params = (category,) if category else ()
    cur.execute(
        f"""
        SELECT * FROM products
        WHERE category IN ({_CLOTHING_CATEGORY_SQL})
          AND (name LIKE %s OR brand LIKE %s OR category LIKE %s)
          {category_filter}
        ORDER BY
          CASE WHEN name LIKE %s THEN 0 WHEN brand LIKE %s THEN 1 ELSE 2 END,
          reviews DESC,
          id DESC
        """,
        (
            *CLOTHING_CATEGORIES,
            like, like, like,
            *category_params,
            like, like
        )
    )
    direct_matches = cur.fetchall()
    if not direct_matches or len(direct_matches) >= limit:
        return direct_matches[:limit]

    cur.execute(
        f"SELECT * FROM products WHERE category IN ({_CLOTHING_CATEGORY_SQL})"
        f"{category_filter}",
        (*CLOTHING_CATEGORIES, *category_params)
    )
    candidates = cur.fetchall()
    direct_ids = {product['id'] for product in direct_matches}
    family = product_family(query)
    primary_category = category or direct_matches[0]['category']
    style_neighbours = {
        'Korean Fashion': ('Streetwear', 'Western Wear'),
        'Streetwear': ('Korean Fashion', 'Western Wear'),
        'Western Wear': ('Streetwear', 'Korean Fashion')
    }
    neighbour_categories = style_neighbours.get(primary_category, ())
    candidates = [product for product in candidates if product['id'] not in direct_ids]
    candidates.sort(
        key=lambda product: (
            product_family(product['name']) != family if family else True,
            product['category'] != primary_category,
            product['category'] not in neighbour_categories,
            not product['trending'],
            -product['reviews'],
            -product['id']
        )
    )
    return (direct_matches + candidates)[:limit]


@app.context_processor
def inject_globals():
    cart = session.get('cart', {})
    cart_count = sum(item.get('quantity', 0) for item in cart.values())
    return {
        'cart_count': cart_count,
        'logged_user': session.get('user')
    }


@app.route('/')
def home():
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute(
        f"SELECT * FROM products WHERE category IN ({_CLOTHING_CATEGORY_SQL}) "
        "AND featured=1 ORDER BY id DESC LIMIT 5",
        CLOTHING_CATEGORIES
    )
    deals = cur.fetchall()

    cur.execute(
        f"SELECT * FROM products WHERE category IN ({_CLOTHING_CATEGORY_SQL}) "
        "AND trending=1 ORDER BY id DESC",
        CLOTHING_CATEGORIES
    )
    trending = cur.fetchall()

    cur.execute(
        "SELECT * FROM products WHERE category=%s ORDER BY featured DESC, reviews DESC LIMIT 6",
        ("Korean Fashion",)
    )
    korean_styles = cur.fetchall()

    cur.execute(
        f"SELECT * FROM categories WHERE name IN ({_CLOTHING_CATEGORY_SQL}) "
        "ORDER BY id",
        CLOTHING_CATEGORIES
    )
    categories = cur.fetchall()

    cur.close()
    db.close()

    return render_template(
        'index.html',
        deals=deals,
        trending=trending,
        korean_styles=korean_styles,
        categories=categories
    )


@app.route('/products')
def products():
    category = request.args.get('category', '')
    q = request.args.get('q', '').strip()

    db = get_db()
    cur = db.cursor(dictionary=True)

    if category:
        items = search_catalog(cur, q, category) if (
            category in CLOTHING_CATEGORIES and q
        ) else []
        if category in CLOTHING_CATEGORIES and not q:
            cur.execute(
                "SELECT * FROM products WHERE category=%s ORDER BY id DESC",
                (category,)
            )
            items = cur.fetchall()
    else:
        if q:
            items = search_catalog(cur, q)
        else:
            cur.execute(
                f"SELECT * FROM products WHERE category IN ({_CLOTHING_CATEGORY_SQL}) "
                "ORDER BY id DESC",
                CLOTHING_CATEGORIES
            )
            items = cur.fetchall()

    cur.execute(
        f"SELECT * FROM categories WHERE name IN ({_CLOTHING_CATEGORY_SQL}) "
        "ORDER BY id",
        CLOTHING_CATEGORIES
    )
    categories = cur.fetchall()

    cur.close()
    db.close()

    return render_template(
        'products.html',
        products=items,
        categories=categories,
        category=category,
        q=q
    )


@app.route('/product/<int:product_id>')
def product(product_id):
    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute(
        f"SELECT * FROM products WHERE id=%s "
        f"AND category IN ({_CLOTHING_CATEGORY_SQL})",
        (product_id, *CLOTHING_CATEGORIES)
    )
    item = cur.fetchone()

    cur.execute(
        f"SELECT * FROM products WHERE id<>%s "
        f"AND category IN ({_CLOTHING_CATEGORY_SQL})",
        (product_id, *CLOTHING_CATEGORIES)
    )
    candidates = cur.fetchall()

    cur.close()
    db.close()

    if not item:
        return redirect(url_for('home'))

    family = product_family(item['name'])
    candidates.sort(
        key=lambda candidate: (
            product_family(candidate['name']) != family if family else True,
            candidate['category'] != item['category'],
            not candidate['featured'],
            not candidate['trending'],
            -candidate['reviews']
        )
    )
    related = candidates[:4]
    related_title = (
        f"More {family} styles"
        if family
        else f"More from {item['category']}"
    )

    return render_template(
        'product.html',
        product=item,
        related=related,
        related_title=related_title
    )


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email'].strip().lower()
        password = request.form['password']

        db = get_db()
        cur = db.cursor(dictionary=True)

        cur.execute(
            "SELECT id,name,email,password_hash FROM users WHERE email=%s",
            (email,)
        )
        user = cur.fetchone()

        cur.close()
        db.close()

        if user and check_password_hash(
            user['password_hash'],
            password
        ):
            session['user'] = {
                'id': user['id'],
                'name': user['name'],
                'email': user['email']
            }

            return redirect(
                request.args.get('next') or url_for('home')
            )

        flash('Invalid email or password.', 'error')

    return render_template('login.html')


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name'].strip()
        email = request.form['email'].strip().lower()
        password = request.form['password']

        if len(password) < 6:
            flash(
                'Password must be at least 6 characters.',
                'error'
            )
            return render_template('register.html')

        db = get_db()
        cur = db.cursor()

        try:
            cur.execute(
                """
                INSERT INTO users(name, email, password_hash)
                VALUES(%s, %s, %s)
                """,
                (
                    name,
                    email,
                    generate_password_hash(password)
                )
            )

            db.commit()

            flash(
                'Account created. Please login.',
                'success'
            )

            return redirect(url_for('login'))

        except Exception:
            db.rollback()
            flash(
                'Email already registered.',
                'error'
            )

        finally:
            cur.close()
            db.close()

    return render_template('register.html')


@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect(url_for('home'))


@app.post('/cart/add')
def add_cart():
    pid = str(request.form.get('product_id'))
    qty = max(
        1,
        int(request.form.get('quantity', 1))
    )

    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute(
        f"""
        SELECT id,name,price,image,stock
        FROM products
        WHERE id=%s AND category IN ({_CLOTHING_CATEGORY_SQL})
        """,
        (pid, *CLOTHING_CATEGORIES)
    )

    p = cur.fetchone()

    cur.close()
    db.close()

    if not p:
        return jsonify({
            'ok': False,
            'message': 'Product not found'
        }), 404

    cart = session.get('cart', {})

    if pid in cart:
        cart[pid]['quantity'] += qty
    else:
        cart[pid] = {
            'name': p['name'],
            'price': float(p['price']),
            'image': p['image'],
            'quantity': qty
        }

    session['cart'] = cart
    session.modified = True

    return jsonify({
        'ok': True,
        'cart_count': sum(
            x['quantity']
            for x in cart.values()
        )
    })


@app.post('/buy-now/<int:product_id>')
def buy_now(product_id):
    try:
        quantity = int(request.form.get('quantity', 1))
    except ValueError:
        flash('Please enter a valid quantity.', 'error')
        return redirect(url_for('product', product_id=product_id))

    if quantity < 1:
        flash('Quantity must be at least one.', 'error')
        return redirect(url_for('product', product_id=product_id))

    db = get_db()
    cur = db.cursor(dictionary=True)
    cur.execute(
        f"SELECT id,name,price,image,stock FROM products "
        f"WHERE id=%s AND category IN ({_CLOTHING_CATEGORY_SQL})",
        (product_id, *CLOTHING_CATEGORIES)
    )
    item = cur.fetchone()
    cur.close()
    db.close()

    if not item:
        flash('This product is no longer available.', 'error')
        return redirect(url_for('products'))

    if quantity > item['stock']:
        flash(f"Only {item['stock']} item(s) are currently in stock.", 'error')
        return redirect(url_for('product', product_id=product_id))

    session['cart'] = {
        str(item['id']): {
            'name': item['name'],
            'price': float(item['price']),
            'image': item['image'],
            'quantity': quantity
        }
    }
    session.modified = True
    return redirect(url_for('checkout'))


@app.post('/cart/update')
def update_cart():
    pid = str(request.form.get('product_id'))
    qty = int(request.form.get('quantity', 1))

    cart = session.get('cart', {})

    if pid in cart:
        if qty <= 0:
            cart.pop(pid)
        else:
            cart[pid]['quantity'] = qty

    session['cart'] = cart
    session.modified = True

    return redirect(url_for('cart'))


@app.post('/cart/remove')
def remove_cart():
    pid = str(request.form.get('product_id'))

    cart = session.get('cart', {})
    cart.pop(pid, None)

    session['cart'] = cart
    session.modified = True

    return redirect(url_for('cart'))


def cart_items():
    cart = session.get('cart', {})
    product_ids = []

    for product_id in cart:
        try:
            product_ids.append(int(product_id))
        except ValueError:
            continue

    if not product_ids:
        if cart:
            session['cart'] = {}
            session.modified = True
        return [], Decimal('0')

    db = get_db()
    cur = db.cursor(dictionary=True)
    id_placeholders = ','.join(['%s'] * len(product_ids))
    cur.execute(
        f"SELECT id,name,price,image FROM products "
        f"WHERE id IN ({id_placeholders}) "
        f"AND category IN ({_CLOTHING_CATEGORY_SQL})",
        (*product_ids, *CLOTHING_CATEGORIES)
    )
    products_by_id = {str(p['id']): p for p in cur.fetchall()}
    cur.close()
    db.close()

    items = []
    subtotal = Decimal('0')
    current_cart = {}

    for pid, x in cart.items():
        product = products_by_id.get(pid)
        if not product:
            continue

        quantity = x['quantity']
        total = (
            Decimal(str(product['price']))
            * quantity
        )

        subtotal += total
        current_cart[pid] = {
            'name': product['name'],
            'price': float(product['price']),
            'image': product['image'],
            'quantity': quantity
        }

        items.append({
            'id': pid,
            **current_cart[pid],
            'line_total': float(total)
        })

    if current_cart != cart:
        session['cart'] = current_cart
        session.modified = True

    return items, subtotal


@app.route('/cart')
def cart():
    items, subtotal = cart_items()

    shipping = (
        0
        if subtotal >= 499 or subtotal == 0
        else 49
    )

    total = subtotal + shipping

    return render_template(
        'cart.html',
        items=items,
        subtotal=float(subtotal),
        shipping=shipping,
        total=float(total)
    )


@app.route('/checkout', methods=['GET', 'POST'])
def checkout():

    if not session.get('user'):
        return redirect(
            url_for(
                'login',
                next=url_for('checkout')
            )
        )

    items, subtotal = cart_items()

    if not items:
        return redirect(url_for('cart'))

    shipping = 0 if subtotal >= 499 else 49
    total = subtotal + shipping

    if request.method == 'POST':

        db = get_db()
        cur = db.cursor()

        try:

            cur.execute(
                """
                INSERT INTO orders
                (
                    user_id,
                    total_amount,
                    status,
                    address,
                    city,
                    state,
                    pincode,
                    payment_method
                )
                VALUES(%s,%s,%s,%s,%s,%s,%s,%s)
                """,
                (
                    session['user']['id'],
                    float(total),
                    'Placed',
                    request.form['address'],
                    request.form['city'],
                    request.form['state'],
                    request.form['pincode'],
                    request.form['payment']
                )
            )

            order_id = cur.lastrowid

            for x in items:

                cur.execute(
                    """
                    INSERT INTO order_items
                    (
                        order_id,
                        product_id,
                        quantity,
                        price
                    )
                    VALUES(%s,%s,%s,%s)
                    """,
                    (
                        order_id,
                        int(x['id']),
                        x['quantity'],
                        x['price']
                    )
                )

            db.commit()

            session['cart'] = {}

            flash(
                f'Order #{order_id} placed successfully!',
                'success'
            )

            return redirect(url_for('orders'))

        except Exception:
            db.rollback()

            flash(
                'Order could not be placed. Check database settings.',
                'error'
            )

        finally:
            cur.close()
            db.close()

    return render_template(
        'checkout.html',
        items=items,
        subtotal=float(subtotal),
        shipping=shipping,
        total=float(total)
    )


@app.route('/orders')
def orders():

    if not session.get('user'):
        return redirect(
            url_for(
                'login',
                next=url_for('orders')
            )
        )

    db = get_db()
    cur = db.cursor(dictionary=True)

    cur.execute(
        """
        SELECT *
        FROM orders
        WHERE user_id=%s
        ORDER BY created_at DESC
        """,
        (session['user']['id'],)
    )

    rows = cur.fetchall()

    cur.close()
    db.close()

    return render_template(
        'orders.html',
        orders=rows
    )


@app.get('/api/search')
def api_search():

    q = request.args.get('q', '').strip()

    db = get_db()
    cur = db.cursor(dictionary=True)

    rows = search_catalog(cur, q, limit=12) if q else []
    rows = [
        {key: product[key] for key in ('id', 'name', 'price', 'image')}
        for product in rows
    ]

    cur.close()
    db.close()

    return jsonify(rows)


# ==============================
# START FLASK SERVER
# ==============================

if __name__ == '__main__':
    print("Starting ShopEase...")
    print("Starting Flask server on port 5002...")

    app.run(
        host='127.0.0.1',
        port=5002,
        debug=False,
        use_reloader=False
    )