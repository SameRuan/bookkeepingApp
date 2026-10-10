
import { router } from '@kit.ArkUI';
import { Index_ShowAccounts } from './Index';
import { One } from './One_SelectAccounts';
import { Three } from './Three_ShowAccounts';
import { Two } from './Two_KeepAccounts';

/**
 * 主页面-配置底部导航栏
 */

// 底部导航项数据结构
class NavItem {
  id: string;
  text: string;
  activeIcon: ResourceStr; // 中状态的图标
  unactiveIcon: ResourceStr; // 未选中状态的图标

  constructor(id: string, unactiveIcon: ResourceStr, activeIcon: ResourceStr, text: string) {
    this.id = id;
    this.unactiveIcon = unactiveIcon;
    this.activeIcon = activeIcon;
    this.text = text;
  }
}

interface RouteParams {
  token: string;
  account: string;
}


@Entry
@Component
struct EntryPage_First {
  @State message: string = 'Hello World';
  private tabsController: TabsController = new TabsController()
  @State currentIndex: number = 0; // 新增：当前选中的索引
  @State receivedToken: string = '';
  @State receivedAccount: string = '';
  // 底部导航数据 - 需要你为每个图标准备两种状态（选中和未选中）
  @State navList: NavItem[] = [
    new NavItem('1', $r('app.media.shouye'), $r('app.media.shouye1'), '账本'),
    new NavItem('2', $r('app.media.jizhang'), $r('app.media.jizhang1'), '查询'),
    new NavItem('3', $r('app.media.fangsong'), $r('app.media.fangsong1'), '记一笔'),
    new NavItem('4', $r('app.media.wode'), $r('app.media.wode1'), '统计')
  ];

  onPageShow() {
    const params = router.getParams() as RouteParams; // 类型断言
    if (params) {
      this.receivedToken = params.token; // 使用点符号访问
      this.receivedAccount = params.account;
    }
  }



  // 自定义TabBar构建函数
  @Builder TabBarBuilder(item: NavItem, index: number) {
    Column({ space: 4 }) {
      // 根据是否选中显示不同的图标
      Image(this.currentIndex === index ? item.activeIcon : item.unactiveIcon)
        .width(24)
        .height(24)
        // .backgroundColor(Color.Red)
        .objectFit(ImageFit.Auto)
      // 根据是否选中设置不同的文字颜色
      Text(item.text)
        .fontSize(14)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#ff000000') // 选中时蓝色，未选中时黑色
    }

    .width('100%')
    .padding({ left: 8, right: 8, top: 4 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
      // index === 1 是查询 tab
    })
  }




  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController
    }) {
      TabContent() {
        Column() {
          Index_ShowAccounts()
        }
      }.tabBar(this.TabBarBuilder(this.navList[0], 0))

      TabContent() {
        Column() {
          One()
        }
      }.tabBar(this.TabBarBuilder(this.navList[1], 1))

      TabContent() {
        Column() {
          Two()
        }
      }.tabBar(this.TabBarBuilder(this.navList[2], 2))

      TabContent() {
        Column() {
          Three()
        }
      }.tabBar(this.TabBarBuilder(this.navList[3], 3))
    }
    .scrollable(false)
  }
}


