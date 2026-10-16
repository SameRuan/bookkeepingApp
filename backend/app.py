from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
from database import (
    init_db, find_user, add_bill, list_bills,
    delete_bill, query_bills, DB_PATH
)
app = Flask(__name__)
CORS(app)  # 允许跨域，便于前端/测试访问

# 统一响应格式：{code, msg, data}
def ok(data=None, msg='成功'):
    return jsonify({'code': 200, 'msg': msg, 'data': data})

def fail(code=400, msg='请求错误'):
    return jsonify({'code': code, 'msg': msg, 'data': None}), code


# ==================== 登录接口 ====================
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json(silent=True) or {}
    username = (data.get('username') or '').strip()
    password = (data.get('password') or '').strip()

    if not username or not password:
        return fail(400, '用户名或密码不能为空')

    user = find_user(username, password)
    if user:
        return ok({'token': f'mock-token-{user["id"]}', 'username': username}, '登录成功')
    return fail(401, '用户名或密码错误')


# ==================== 账单增删查 ====================
@app.route('/api/bills', methods=['GET'])
def get_bills():
    return ok(list_bills())


@app.route('/api/bills', methods=['POST'])
def create_bill():
    data = request.get_json(silent=True) or {}
    text = (data.get('text') or '').strip()
    name = (data.get('name') or '').strip()
    price = data.get('price')
    is_income = bool(data.get('isIncome', False))
    date = (data.get('date') or datetime.now().strftime('%Y-%m-%d')).strip()

    # 参数校验 —— 覆盖异常场景与边界值
    if not text:
        return fail(400, '类型不能为空')
    if not name:
        return fail(400, '备注不能为空')
    if price is None or price == '':
        return fail(400, '金额不能为空')

    try:
        price = float(price)
    except (TypeError, ValueError):
        return fail(400, '金额必须为数字')

    if price <= 0:
        return fail(400, '金额必须大于0')
    if price > 1_000_000:
        return fail(400, '金额超出合理范围')

    create_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    bill_id = add_bill(text, name, price, is_income, date,
                       data.get('imageName', ''), create_time)
    return ok({'id': bill_id}, '记账成功')


@app.route('/api/bills/<int:bill_id>', methods=['DELETE'])
def remove_bill(bill_id):
    if delete_bill(bill_id):
        return ok(msg='删除成功')
    return fail(404, '账单不存在')


# ==================== 查询接口 ====================
@app.route('/api/bills/query', methods=['GET'])
def query():
    bill_type = request.args.get('type')
    start_date = request.args.get('startDate')
    end_date = request.args.get('endDate')
    keyword = request.args.get('keyword')

    # 金额区间需要转 float，非法值直接返回400
    min_amount = request.args.get('minAmount')
    max_amount = request.args.get('maxAmount')
    try:
        min_amount = float(min_amount) if min_amount not in (None, '') else None
        max_amount = float(max_amount) if max_amount not in (None, '') else None
    except ValueError:
        return fail(400, '金额区间必须为数字')

    # 日期格式简单校验
    for d in (start_date, end_date):
        if d:
            try:
                datetime.strptime(d, '%Y-%m-%d')
            except ValueError:
                return fail(400, '日期格式应为YYYY-MM-DD')

    if start_date and end_date and start_date > end_date:
        return fail(400, '结束日期不能早于开始日期')

    result = query_bills(bill_type, start_date, end_date,
                         min_amount, max_amount, keyword)
    return ok(result)


# ==================== 统计接口 ====================
@app.route('/api/statistics', methods=['GET'])
def statistics():
    bills = list_bills()
    total_income = 0.0
    total_expense = 0.0
    expense_ratio = {}
    income_ratio = {}

    for b in bills:
        price = float(b['price'])
        if b['isIncome']:
            total_income += price
            income_ratio[b['text']] = income_ratio.get(b['text'], 0) + price
        else:
            total_expense += price
            expense_ratio[b['text']] = expense_ratio.get(b['text'], 0) + price

    def to_percent(m):
        total = sum(m.values())
        if total == 0:
            return []
        return [{'name': k, 'ratio': round(v / total * 100)} for k, v in m.items()]

    return ok({
        'totalIncome': round(total_income, 2),
        'totalExpense': round(total_expense, 2),
        'balance': round(total_income - total_expense, 2),
        'expenseRatio': to_percent(expense_ratio),
        'incomeRatio': to_percent(income_ratio),
        'count': len(bills)
    })


# ==================== 启动 ====================
if __name__ == '__main__':
    import os
    init_db()
    port = int(os.environ.get('JIZHANG_PORT', '5000'))
    debug = os.environ.get('JIZHANG_DEBUG', 'true').lower() == 'true'
    print(f'数据库文件: {DB_PATH}')
    print(f'服务端口: {port}    调试模式: {debug}')
    print('服务启动中...')
    app.run(host='0.0.0.0', port=port, debug=debug)