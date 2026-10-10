import { promptAction } from '@kit.ArkUI';
import { kvStoreUtils } from '../common/KVStoreUtils';

//登录页
@Entry
@Component
struct LoginPage_First {
  @State account: string = '';
  @State password: string = '';

  // 内置账号（如需真正注册/多账号，可改成从 kvStoreUtils 里读取）
  private readonly DEFAULT_ACCOUNT: string = 'admin';
  private readonly DEFAULT_PASSWORD: string = '123456';

  async aboutToAppear() {
    // 初始化键值型数据库（与其它页面保持一致）
    kvStoreUtils.init(getContext());
    kvStoreUtils.createKVStore().catch((err: Error) => {
      console.error('KVStore初始化失败:', err);
    });
  }

  // 登录按钮逻辑
  doLogin() {
    const account = this.account.trim();
    if (account.length === 0) {
      promptAction.showToast({ message: '请输入账号' });
      return;
    }
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }

    if (account === this.DEFAULT_ACCOUNT && this.password === this.DEFAULT_PASSWORD) {
      // 记录登录状态，供其它页面使用
      AppStorage.setOrCreate('isLogin', true);
      AppStorage.setOrCreate('loginAccount', account);
      promptAction.showToast({ message: '登录成功' });

      // 用 UIContext 的 router，和项目里其它页面保持一致
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/EntryPage' })
        .catch((err: Error) => {
          console.error('跳转失败:', JSON.stringify(err));
          promptAction.showToast({ message: '跳转失败，请检查路由配置' });
        });
    } else {
      promptAction.showToast({ message: '账号或密码错误' });
    }
  }

  build() {
    Column() {
      // ---------------- 顶部 Logo + 标题 ----------------
      Column({ space: 10 }) {
        Column() {
          Image($r('app.media.shouye'))
            .width(46)
            .height(46)
            .objectFit(ImageFit.Contain)
            .fillColor('#E68A2E')
        }
        .width(86)
        .height(86)
        .borderRadius(43)
        .backgroundColor('#FFE0B2')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Text('记账本')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5C3B1F')

        Text('记录每一笔收支')
          .fontSize(13)
          .fontColor('#8B5A2B')
          .opacity(0.8)
      }
      .margin({ bottom: 40 })

      // ---------------- 表单卡片 ----------------
      Column({ space: 16 }) {
        // 账号
        TextInput({ placeholder: '请输入账号', text: this.account })
          .placeholderColor('#BBBBBB')
          .fontSize(15)
          .fontColor('#333333')
          .height(46)
          .width('100%')
          .backgroundColor('#F5F0EA')
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.account = value;
          })

        // 密码
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .showPasswordIcon(true)
          .placeholderColor('#BBBBBB')
          .fontSize(15)
          .fontColor('#333333')
          .height(46)
          .width('100%')
          .backgroundColor('#F5F0EA')
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.password = value;
          })

        // 登录按钮
        Button('登 录')
          .width('100%')
          .height(46)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF9907')
          .opacity(0.9)
          .borderRadius(23)
          .margin({ top: 6 })
          .onClick(() => {
            this.doLogin();
          })

        Text('默认账号：admin    密码：123456')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('86%')
      .padding({ left: 20, right: 20, top: 26, bottom: 26 })
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .shadow({ radius: 8, color: '#0000001A', offsetY: 3 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF4E8')
    .justifyContent(FlexAlign.Center)
    .padding({ bottom: 60 })
  }
}