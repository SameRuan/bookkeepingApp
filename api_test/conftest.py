import pytest
import requests
import subprocess
import sys
import os
import time

# ==================== 测试环境配置 ====================
TEST_PORT = 5001
TEST_DB = 'test_jizhang.db'
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BACKEND_DIR = os.path.join(PROJECT_ROOT, 'backend')


@pytest.fixture(scope="session", autouse=True)
def test_server():
    """自动启动测试服务（独立数据库 + 独立端口）"""
    test_db_path = os.path.join(BACKEND_DIR, TEST_DB)

    # 1. 清理旧的测试数据库
    if os.path.exists(test_db_path):
        try:
            os.remove(test_db_path)
            print(f'\n[setup] 已删除旧的测试数据库: {TEST_DB}')
        except Exception as e:
            print(f'\n[setup] 删除测试数据库失败: {e}')

    # 2. 启动测试服务
    env = os.environ.copy()
    env['JIZHANG_DB'] = TEST_DB
    env['JIZHANG_PORT'] = str(TEST_PORT)
    env['JIZHANG_DEBUG'] = 'false'  # 关闭debug，防止reloader产生子进程

    print(f'[setup] 启动测试服务 http://127.0.0.1:{TEST_PORT}')
    process = subprocess.Popen(
        [sys.executable, 'app.py'],
        cwd=BACKEND_DIR,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    # 3. 等待服务就绪
    max_wait = 15
    ready = False
    for i in range(max_wait):
        time.sleep(1)
        try:
            resp = requests.get(f'http://127.0.0.1:{TEST_PORT}/api/bills', timeout=1)
            if resp.status_code == 200:
                print(f'[setup] 测试服务已就绪（用时{i + 1}秒）')
                ready = True
                break
        except Exception:
            pass

    if not ready:
        process.kill()
        process.wait()
        raise RuntimeError(f'测试服务启动失败，等待{max_wait}秒后仍未就绪')

    yield

    # 4. 关闭测试服务
    print('\n[teardown] 关闭测试服务')
    try:
        process.terminate()
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()

    # 5. 删除测试数据库
    time.sleep(1)
    if os.path.exists(test_db_path):
        try:
            os.remove(test_db_path)
            print(f'[teardown] 已删除测试数据库: {TEST_DB}')
        except Exception as e:
            print(f'[teardown] 删除测试数据库失败: {e}')


@pytest.fixture(scope="session")
def base_url():
    """测试服务地址（端口5001，独立于正式服务）"""
    return f"http://127.0.0.1:{TEST_PORT}"


@pytest.fixture(scope="session")
def session():
    s = requests.Session()
    yield s
    s.close()


@pytest.fixture(scope="session")
def auth_token(session, base_url):
    resp = session.post(f"{base_url}/api/login",
                        json={"username": "admin", "password": "123456"})
    return resp.json().get("data", {}).get("token", "")