import pytest
import allure


@allure.feature("账单模块")
class TestBills:
    """账单接口测试：新增、查询、删除"""

    # ---------------- 正常流程 ----------------

    @allure.story("正常流程")
    @allure.title("新增支出账单成功")
    def test_add_expense_success(self, session, base_url):
        payload = {"text": "餐饮", "name": "午餐", "price": 25.5, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 200
        body = resp.json()
        assert body["code"] == 200
        assert body["data"]["id"] > 0

    @allure.story("正常流程")
    @allure.title("新增收入账单成功")
    def test_add_income_success(self, session, base_url):
        payload = {"text": "工资", "name": "月薪", "price": 8000, "isIncome": True}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 200
        assert resp.json()["code"] == 200

    @allure.story("正常流程")
    @allure.title("获取账单列表")
    def test_get_bills_list(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills")
        assert resp.status_code == 200
        assert resp.json()["code"] == 200
        assert isinstance(resp.json()["data"], list)

    # ---------------- 异常场景 ----------------

    @allure.story("异常场景")
    @allure.title("备注为空应被拒绝")
    def test_add_bill_empty_name(self, session, base_url):
        payload = {"text": "餐饮", "name": "", "price": 25.5, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 400
        assert resp.json()["code"] == 400

    @allure.story("异常场景")
    @allure.title("类型为空应被拒绝")
    def test_add_bill_empty_text(self, session, base_url):
        payload = {"text": "", "name": "午餐", "price": 25.5, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 400

    @allure.story("异常场景")
    @allure.title("金额非数字应被拒绝")
    def test_add_bill_invalid_price(self, session, base_url):
        payload = {"text": "餐饮", "name": "午餐", "price": "abc", "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 400

    @allure.story("异常场景")
    @allure.title("金额为空应被拒绝")
    def test_add_bill_empty_price(self, session, base_url):
        payload = {"text": "餐饮", "name": "午餐", "price": "", "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 400

    # ---------------- 边界值 ----------------

    @allure.story("边界值")
    @allure.title("金额为0应被拒绝")
    def test_add_bill_zero_price(self, session, base_url):
        payload = {"text": "餐饮", "name": "午餐", "price": 0, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 400

    @allure.story("边界值")
    @allure.title("金额为负数应被拒绝")
    def test_add_bill_negative_price(self, session, base_url):
        payload = {"text": "餐饮", "name": "午餐", "price": -10, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 400

    @allure.story("边界值")
    @allure.title("金额为极小值(0.01)应成功")
    def test_add_bill_min_price(self, session, base_url):
        payload = {"text": "餐饮", "name": "最小金额", "price": 0.01, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 200

    @allure.story("边界值")
    @allure.title("金额为极大值(1000000)应成功")
    def test_add_bill_max_price(self, session, base_url):
        payload = {"text": "餐饮", "name": "最大金额", "price": 1000000, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 200

    @allure.story("边界值")
    @allure.title("金额超过合理范围(1000000以上)应被拒绝")
    def test_add_bill_over_max_price(self, session, base_url):
        payload = {"text": "餐饮", "name": "超限", "price": 1000001, "isIncome": False}
        resp = session.post(f"{base_url}/api/bills", json=payload)
        assert resp.status_code == 400


@allure.feature("账单删除模块")
class TestDeleteBill:

    @allure.story("正常流程")
    @allure.title("删除已有账单成功")
    def test_delete_existing_bill(self, session, base_url):
        # 先新增一条
        add_resp = session.post(f"{base_url}/api/bills",
                                json={"text": "测试", "name": "待删除", "price": 1, "isIncome": False})
        bill_id = add_resp.json()["data"]["id"]
        # 再删除
        resp = session.delete(f"{base_url}/api/bills/{bill_id}")
        assert resp.status_code == 200
        assert resp.json()["code"] == 200

    @allure.story("异常场景")
    @allure.title("删除不存在的账单返回404")
    def test_delete_not_exist_bill(self, session, base_url):
        resp = session.delete(f"{base_url}/api/bills/999999")
        assert resp.status_code == 404