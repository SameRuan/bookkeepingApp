import pytest
import allure


@allure.feature("登录模块")
class TestLogin:

    @allure.story("正常流程")
    @allure.title("使用正确账号密码登录成功")
    def test_login_success(self, session, base_url):
        resp = session.post(f"{base_url}/api/login",
                            json={"username": "admin", "password": "123456"})
        assert resp.status_code == 200
        body = resp.json()
        assert body["code"] == 200
        assert body["data"]["token"] is not None

    @allure.story("异常场景")
    @allure.title("密码错误登录失败")
    def test_login_wrong_password(self, session, base_url):
        resp = session.post(f"{base_url}/api/login",
                            json={"username": "admin", "password": "wrong"})
        assert resp.status_code == 401
        assert resp.json()["code"] == 401

    @allure.story("异常场景")
    @allure.title("用户名错误登录失败")
    def test_login_wrong_username(self, session, base_url):
        resp = session.post(f"{base_url}/api/login",
                            json={"username": "guest", "password": "123456"})
        assert resp.status_code == 401
        assert resp.json()["code"] == 401

    @allure.story("边界值")
    @allure.title("用户名为空")
    def test_login_empty_username(self, session, base_url):
        resp = session.post(f"{base_url}/api/login",
                            json={"username": "", "password": "123456"})
        assert resp.status_code == 400

    @allure.story("边界值")
    @allure.title("密码为空")
    def test_login_empty_password(self, session, base_url):
        resp = session.post(f"{base_url}/api/login",
                            json={"username": "admin", "password": ""})
        assert resp.status_code == 400

    @allure.story("异常场景")
    @allure.title("请求体完全为空")
    def test_login_empty_body(self, session, base_url):
        resp = session.post(f"{base_url}/api/login", json={})
        assert resp.status_code == 400