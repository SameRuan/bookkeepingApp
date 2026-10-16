import allure


@allure.feature("统计模块")
class TestStatistics:

    @allure.story("正常流程")
    @allure.title("获取统计数据")
    def test_get_statistics(self, session, base_url):
        resp = session.get(f"{base_url}/api/statistics")
        assert resp.status_code == 200
        data = resp.json()["data"]
        # 校验必要字段存在
        for key in ["totalIncome", "totalExpense", "balance",
                    "expenseRatio", "incomeRatio", "count"]:
            assert key in data

    @allure.story("业务流程链路")
    @allure.title("记一笔后统计金额同步更新")
    def test_statistics_after_add(self, session, base_url):
        # 记录初始支出
        before = session.get(f"{base_url}/api/statistics").json()["data"]["totalExpense"]

        # 新增一笔 88.88 的支出
        session.post(f"{base_url}/api/bills",
                     json={"text": "测试", "name": "统计测试",
                           "price": 88.88, "isIncome": False})

        # 再次获取支出
        after = session.get(f"{base_url}/api/statistics").json()["data"]["totalExpense"]

        # 支出应增加 88.88
        assert round(after - before, 2) == 88.88

    @allure.story("正常流程")
    @allure.title("余额 = 收入 - 支出")
    def test_balance_formula(self, session, base_url):
        data = session.get(f"{base_url}/api/statistics").json()["data"]
        assert round(data["balance"], 2) == round(data["totalIncome"] - data["totalExpense"], 2)