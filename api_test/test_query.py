import allure


@allure.feature("查询模块")
class TestQuery:

    @allure.story("正常流程")
    @allure.title("无条件查询返回全部账单")
    def test_query_all(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query")
        assert resp.status_code == 200
        assert isinstance(resp.json()["data"], list)

    @allure.story("正常流程")
    @allure.title("按支出类型查询")
    def test_query_expense(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query", params={"type": "expense"})
        assert resp.status_code == 200
        for item in resp.json()["data"]:
            assert item["isIncome"] == 0

    @allure.story("正常流程")
    @allure.title("按收入类型查询")
    def test_query_income(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query", params={"type": "income"})
        assert resp.status_code == 200
        for item in resp.json()["data"]:
            assert item["isIncome"] == 1

    @allure.story("正常流程")
    @allure.title("按关键词查询")
    def test_query_keyword(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query", params={"keyword": "午餐"})
        assert resp.status_code == 200

    @allure.story("正常流程")
    @allure.title("按金额区间查询")
    def test_query_amount_range(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query",
                           params={"minAmount": 10, "maxAmount": 100})
        assert resp.status_code == 200
        for item in resp.json()["data"]:
            assert 10 <= item["price"] <= 100

    @allure.story("异常场景")
    @allure.title("日期格式错误应被拒绝")
    def test_query_invalid_date(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query",
                           params={"startDate": "2024/10/01"})
        assert resp.status_code == 400

    @allure.story("边界值")
    @allure.title("结束日期早于开始日期应被拒绝")
    def test_query_date_reversed(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query",
                           params={"startDate": "2024-12-31", "endDate": "2024-01-01"})
        assert resp.status_code == 400

    @allure.story("边界值")
    @allure.title("金额区间为非法值应被拒绝")
    def test_query_invalid_amount(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query",
                           params={"minAmount": "abc"})
        assert resp.status_code == 400

    @allure.story("边界值")
    @allure.title("查询不存在的关键词返回空列表")
    def test_query_no_result(self, session, base_url):
        resp = session.get(f"{base_url}/api/bills/query",
                           params={"keyword": "绝对不会存在的关键词xyz123"})
        assert resp.status_code == 200
        assert resp.json()["data"] == []