import sqlite3
import os

# 支持环境变量切换数据库：正式环境用 jizhang.db，测试环境用 test_jizhang.db
DB_PATH = os.path.join(os.path.dirname(__file__),
                       os.environ.get('JIZHANG_DB', 'jizhang.db'))

def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """初始化数据库表"""
    conn = get_conn()
    cursor = conn.cursor()
    # 用户表
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        )
    ''')
    # 账单表
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS bills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            isIncome INTEGER NOT NULL,
            date TEXT NOT NULL,
            imageName TEXT,
            createTime TEXT,
            user_id INTEGER
        )
    ''')
    # 插入默认用户 admin / 123456
    cursor.execute("SELECT COUNT(*) FROM users WHERE username='admin'")
    if cursor.fetchone()[0] == 0:
        cursor.execute("INSERT INTO users (username, password) VALUES (?, ?)",
                       ('admin', '123456'))
    conn.commit()
    conn.close()

# ---------- 用户相关 ----------
def find_user(username, password):
    conn = get_conn()
    row = conn.execute(
        "SELECT * FROM users WHERE username=? AND password=?",
        (username, password)
    ).fetchone()
    conn.close()
    return dict(row) if row else None

# ---------- 账单相关 ----------
def add_bill(text, name, price, is_income, date, image_name='', create_time=''):
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO bills (text, name, price, isIncome, date, imageName, createTime) VALUES (?,?,?,?,?,?,?)",
        (text, name, price, 1 if is_income else 0, date, image_name, create_time)
    )
    bill_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return bill_id

def list_bills():
    conn = get_conn()
    rows = conn.execute("SELECT * FROM bills ORDER BY id DESC").fetchall()
    conn.close()
    return [dict(r) for r in rows]

def delete_bill(bill_id):
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM bills WHERE id=?", (bill_id,))
    affected = cursor.rowcount
    conn.commit()
    conn.close()
    return affected > 0

def query_bills(bill_type=None, start_date=None, end_date=None,
                min_amount=None, max_amount=None, keyword=None):
    conn = get_conn()
    sql = "SELECT * FROM bills WHERE 1=1"
    params = []
    if bill_type == 'expense':
        sql += " AND isIncome=0"
    elif bill_type == 'income':
        sql += " AND isIncome=1"
    if start_date:
        sql += " AND date>=?"
        params.append(start_date)
    if end_date:
        sql += " AND date<=?"
        params.append(end_date)
    if min_amount is not None:
        sql += " AND price>=?"
        params.append(min_amount)
    if max_amount is not None:
        sql += " AND price<=?"
        params.append(max_amount)
    if keyword:
        sql += " AND (text LIKE ? OR name LIKE ?)"
        params.extend([f"%{keyword}%", f"%{keyword}%"])
    sql += " ORDER BY id DESC"
    rows = conn.execute(sql, params).fetchall()
    conn.close()
    return [dict(r) for r in rows]