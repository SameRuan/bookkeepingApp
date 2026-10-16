import { promptAction } from '@kit.ArkUI';
import { HttpUtil, LoginData, LoginRequest } from '../utils/HttpUtil';

/*
 * 登录页面
 * */
@Entry
@Component
struct LoginPage_First {
  @State account: string = '';
  @State password: string = '';

  async doLogin() {
    const account = this.account.trim();
    if (account.length === 0) {
      promptAction.showToast({ message: '请输入账号' });
      return;
    }
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }

    try {
      const reqBody: LoginRequest = {
        username: account,
        password: this.password
      };
      const res = await HttpUtil.post<LoginData>('/api/login', reqBody);
      if (res.code === 200) {
        AppStorage.setOrCreate('isLogin', true);
        AppStorage.setOrCreate('loginAccount', account);
        AppStorage.setOrCreate('token', res.data.token);
        promptAction.showToast({ message: '登录成功' });
        this.getUIContext().getRouter().replaceUrl({ url: 'pages/EntryPage' })
          .catch((err: Error) => {
            console.error('跳转失败:', JSON.stringify(err));
            promptAction.showToast({ message: '跳转失败，请检查路由配置' });
          });
      } else {
        promptAction.showToast({ message: res.msg || '账号或密码错误' });
      }
    } catch (err) {
      console.error('登录失败:', JSON.stringify(err));
      promptAction.showToast({ message: '网络请求失败，请检查后端是否启动' });
    }
  }

  build() {
    Column() {
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

      Column({ space: 16 }) {
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
