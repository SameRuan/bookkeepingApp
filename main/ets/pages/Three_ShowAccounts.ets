import { promptAction, router } from '@kit.ArkUI';
import { kvStoreUtils } from '../common/KVStoreUtils';
import { KeepAccountsModel, TopBack } from '../components/top';

// 账单条目接口
export interface Bill {
  text: string,
  name: string,
  price: string,
  imageName: string,
  isIncome: boolean
}

// 收支占比类型接口
export interface RatioItem {
  name: string;
  ratio: number;
}

// 分类金额统计Map类型
type AmountMap = Record<string, number>;

@Entry
@Component
export struct Three {
  async aboutToAppear() {
    kvStoreUtils.init(getContext())
    kvStoreUtils.createKVStore().then(() => {
      console.log('KVStore初始化成功')
      this.loadBillData();
    }).catch((err: Error) => {
      console.error('KVStore初始化失败:', err)
    })
  }

  expensesList: KeepAccountsModel[] = [
    { text: '餐饮', imageName: 'cy', icon: $r('app.media.cy') },
    { text: '购物', imageName: 'gw', icon: $r('app.media.gw') },
    { text: '交通', imageName: 'ryp', icon: $r('app.media.ryp') },
    { text: '其他', imageName: 'jt', icon: $r('app.media.jt') }
  ]

  incomeList: KeepAccountsModel[] = [
    { text: '工资', imageName: 'gz', icon: $r('app.media.gz') },
    { text: '兼职', imageName: 'jz', icon: $r('app.media.jz') },
    { text: '窝囊费', imageName: 'lc', icon: $r('app.media.lc') },
    { text: '其他', imageName: 'qt', icon: $r('app.media.qt') }
  ]

  @State totalIncome: number = 0;
  @State totalExpense: number = 0;
  @State balance: number = 0;
  @State billList: Bill[] = [];
  @State expenseRatio: RatioItem[] = [];
  @State incomeRatio: RatioItem[] = [];

  build() {
    Column({ space: 0 }) {
      // 第1行：标题栏

      TopBack({ title: '账单统计' })
        .backgroundColor('#FFF9E8')


      // 第2行：收支汇总卡片
      Column({ space: 10 }) {
        Text(`总收入：${this.totalIncome.toFixed(0)}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Text(`总支出：${this.totalExpense.toFixed(0)}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Text(`结  余：${this.balance.toFixed(0)}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('90%')
      .padding({top:20,bottom:20,left:24,right:20})
      .backgroundColor('#FFF')
      .margin({ top: 10 })
      .borderRadius(16)
      .shadow({
        radius:8,
        color:"#0000001A"
      })

      // 第3行：支出分类占比（两行布局，匹配效果图餐饮/交通、购物/其他分行）
      Column({ space: 8 }) {
        Text('支出分类占比')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
        // 第一行：餐饮、交通
        Row({ space: 60 }) {
          ForEach(this.expenseRatio.filter((_, idx) => idx < 2), (item: RatioItem) => {
            Text(`■${item.name} ${item.ratio}%`)
              .fontSize(14)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        // 第二行：购物、其他
        Row({ space: 60 }) {
          ForEach(this.expenseRatio.filter((_, idx) => idx >= 2), (item: RatioItem) => {
            Text(`■${item.name} ${item.ratio}%`)
              .fontSize(14)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFF')
      .margin({ top: 10 })
      .borderRadius(16)


      // 第4行：收入分类占比（两行布局，工资/窝囊费、兼职/其他分行）
      Column({ space: 8 }) {
        Text('收入分类占比')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
        // 第一行：工资、窝囊费
        Row({ space: 60 }) {
          ForEach(this.incomeRatio.filter((_, idx) => idx < 2), (item: RatioItem) => {
            Text(`■${item.name} ${item.ratio}%`)
              .fontSize(14)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        // 第二行：兼职、其他
        Row({ space: 60 }) {
          ForEach(this.incomeRatio.filter((_, idx) => idx >= 2), (item: RatioItem) => {
            Text(`■${item.name} ${item.ratio}%`)
              .fontSize(14)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFF')
      .margin({ top: 10 })
      .borderRadius(16)


    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF4E8')
  }

  // 加载账单（兼容KVStore多类型回调参数）
  async loadBillData() {
    kvStoreUtils.getData('keepAccountsKey', (data?: string | number | boolean | Uint8Array) => {
      if (typeof data === 'string' && data) {
        this.billList = JSON.parse(data) as Bill[];
        this.calculateTotal();
        this.calculateRatio();
      }
    })
  }

  // 计算总收支
  calculateTotal() {
    let income = 0;
    let expense = 0;
    this.billList.forEach((item: Bill) => {
      const price = parseFloat(item.price) || 0;
      if (item.isIncome) {
        income += price;
      } else {
        expense += price;
      }
    })
    this.totalIncome = income;
    this.totalExpense = expense;
    this.balance = income - expense;
  }

  // 计算分类占比
  calculateRatio() {
    const expenseMap: AmountMap = {};
    let expenseTotal = 0;
    this.billList.filter((i: Bill) => !i.isIncome).forEach((item: Bill) => {
      const p = parseFloat(item.price) || 0;
      expenseMap[item.text] = (expenseMap[item.text] || 0) + p;
      expenseTotal += p;
    })

    const incomeMap: AmountMap = {};
    let incomeTotal = 0;
    this.billList.filter((i: Bill) => i.isIncome).forEach((item: Bill) => {
      const p = parseFloat(item.price) || 0;
      incomeMap[item.text] = (incomeMap[item.text] || 0) + p;
      incomeTotal += p;
    })

    this.expenseRatio = Object.keys(expenseMap).map((name: string): RatioItem => {
      return {
        name: name,
        ratio: expenseTotal === 0 ? 0 : Math.round((expenseMap[name]/expenseTotal)*100)
      }
    })
    this.incomeRatio = Object.keys(incomeMap).map((name: string): RatioItem => {
      return {
        name: name,
        ratio: incomeTotal === 0 ? 0 : Math.round((incomeMap[name]/incomeTotal)*100)
      }
    })
  }

  // 读取账单工具方法
  getData(result: (success: boolean, data: string) => void) {
    kvStoreUtils.getData('keepAccountsKey', (data?: string | number | boolean | Uint8Array) => {
      if (typeof data === 'string') {
        result(true, data)
      } else {
        result(false, '')
      }
    }, () => result(false, ''))
  }
}
