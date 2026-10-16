import allure


@allure.feature("业务流程链路")
class TestFullFlow:

    @allure.story("端到端业务流程")
    @allure.title("登录→记账→查询→统计全链路")
    def test_full_business_flow(self, session, base_url):
        # 1. 登录
        login_resp = session.post(f"{base_url}/api/login",
                                  json={"username": "admin", "password": "123456"})
        assert login_resp.json()["code"] == 200

        # 2. 记一笔支出
        add_resp = session.post(f"{base_url}/api/bills",
                                json={"text": "交通", "name": "打车",
                                      "price": 35.5, "isIncome": False})
        assert add_resp.json()["code"] == 200

        # 3. 查询该笔账单
        query_resp = session.get(f"{base_url}/api/bills/query",
                                 params={"keyword": "打车"})
        assert query_resp.json()["code"] == 200
        assert len(query_resp.json()["data"]) >= 1

        # 4. 校验统计中支出大于等于35.5
        stat_resp = session.get(f"{base_url}/api/statistics")
        assert stat_resp.json()["data"]["totalExpense"] >= 35.5