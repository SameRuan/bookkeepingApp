import { promptAction, router } from '@kit.ArkUI';
import { kvStoreUtils } from '../common/KVStoreUtils';
import { Top, TopBack } from '../components/top';
import { Bill } from './Two_KeepAccounts';

// 分组数据结构
interface DayData {
  date: string;
  bills: Bill[];
  expense: number;
  income: number;
}

/**
 * 账单展示
 */
@Entry
@Component
export struct Index_ShowAccounts {
  @State listData: Bill[] = []
  @State dayDataList: DayData[] = [] // 存储分组后的数据
  @State PlanExpense: number = 1800
  @State totalExpense: number = 0
  @State rivalExpense: number = this.PlanExpense - this.totalExpense
  @State showBudgetInput: boolean = false // 是否显示预算输入框
  @State tempBudget: string = '' // 临时预算输入值

  async aboutToAppear() {
    this.loadBudget()
    kvStoreUtils.init(getContext())
    kvStoreUtils.createKVStore().then(async () => {
      this.getData(async (success: boolean, data: string) => {
        if (success && data) {
          console.log('获取到的数据:', data)
          this.listData = JSON.parse(data) as Bill[]
          this.processData()
        } else {
          this.listData = []
          this.processData()
        }
      })
    }).catch((err: Error) => {
      console.error('KVStore初始化失败:', err)
    })
  }

  // 处理数据：分组并计算每日收支
  processData() {
    const groups = new Map<string, Bill[]>()
    const expenseMap = new Map<string, number>()
    const incomeMap = new Map<string, number>()

    this.listData.forEach(item => {
      const date = item.date
      if (!groups.has(date)) {
        groups.set(date, [])
        expenseMap.set(date, 0)
        incomeMap.set(date, 0)
      }
      groups.get(date)!.push(item)

      // 计算每日收支
      if (item.isIncome) {
        incomeMap.set(date, (incomeMap.get(date) || 0) + item.price)
      } else {
        expenseMap.set(date, (expenseMap.get(date) || 0) + item.price)
      }
    })

    // 转换为数组并排序
    const sortedDates = Array.from(groups.keys()).sort((a, b) => b.localeCompare(a))
    const dayDataList: DayData[] = []

    sortedDates.forEach(date => {
      dayDataList.push({
        date: date,
        bills: groups.get(date) || [],
        expense: expenseMap.get(date) || 0,
        income: incomeMap.get(date) || 0
      })
    })

    this.dayDataList = dayDataList
    this.ComputeBill()
  }

  // 读取保存的预算
  loadBudget() {
    try {
      const budget = AppStorage.get<number>('monthlyBudget')
      if (budget) {
        this.PlanExpense = budget
        this.rivalExpense = this.PlanExpense - this.totalExpense
      }
    } catch (e) {
      console.error('读取预算失败', e)
    }
  }

  // 保存预算
  saveBudget() {
    AppStorage.setOrCreate('monthlyBudget', this.PlanExpense)
  }

  // 修改预算 - 显示输入框
  editBudget() {
    this.tempBudget = this.PlanExpense.toString()
    this.showBudgetInput = true
  }

  // 确认修改预算
  confirmBudget() {
    const newBudget = parseFloat(this.tempBudget)
    if (!isNaN(newBudget) && newBudget > 0) {
      this.PlanExpense = newBudget
      this.rivalExpense = this.PlanExpense - this.totalExpense
      this.saveBudget()
      promptAction.showToast({ message: `预算已更新为 ${newBudget} 元` })
    } else {
      promptAction.showToast({ message: '请输入有效金额' })
    }
    this.showBudgetInput = false
  }

  // 取消修改预算
  cancelBudget() {
    this.showBudgetInput = false
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      Column({ space: 5 }) {
        this.CardPage()
        this.ListPage()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFF')
      this.ButtonPage()
    }
  }

  @Builder
  ButtonPage() {
    Row() {
      Column(){
        Image($r('app.media.refresh_'))
          .objectFit(ImageFit.Fill)
          .width('100%')
          .height('100%')
          .margin({
            right:20,
            top:-95
          })
          .onClick(() => {
            promptAction.showToast({ message: '刷新完成', duration: 2000 });
            this.onPageShow()
          })
      }
        .height('100%')
        .layoutWeight(1)

        .backgroundColor('#fff')
      .borderRadius(30)
        .opacity(0.8)
    }
    .width(30)
    .height(30)
  }

  @Builder
  ListPage() {
    List({ space: 10 }) {
      ForEach(this.dayDataList, (dayData: DayData) => {
        ListItem() {
          Column() {
            // 日期标题
            this.DateHeader(dayData)
            // 当天账单列表
            this.DayBillsList(dayData.bills)
          }
          .border({width:2,color:'#FFE0B2'})
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .shadow({ radius: 2, color: '#00000010', offsetY: 1 })
        }
      }, (dayData: DayData) => dayData.date)
    }
    .layoutWeight(1)
    .width('100%')
    .padding(10)
  }

  @Builder
  DateHeader(dayData: DayData) {
    Row() {
      Text(this.formatDateDisplay(dayData.date))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5C3B1F')

      Blank()

      Text(`支出: ¥${dayData.expense.toFixed(2)}`)
        .fontSize(12)
        .fontColor('#ffbe2727')

      Text(`  收入: ¥${dayData.income.toFixed(2)}`)
        .fontSize(12)
        .fontColor('#fff8a402')
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 8 })
    .backgroundColor('#FFF4E8')
    .borderRadius({ topLeft: 10, topRight: 10 })
  }

  @Builder
  DayBillsList(bills: Bill[]) {
    Column() {
      ForEach(bills, (item: Bill, index: number) => {
        this.BillItem(item, index === bills.length - 1)
      }, (item: Bill, index: number) => item.name + item.date + index)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ bottomLeft: 10, bottomRight: 10 })
  }

  @Builder
  BillItem(item: Bill, isLast: boolean) {
    Row() {
      // 图标
      Column() {
        Image(this.getImageResource(item.imageName))
          .width(28)
          .height(28)
      }
      .width(40)
      .height(40)
      .backgroundColor('#FFE0A4')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(90)

      // 信息
      Column({ space: 4 }) {
        Text(item.text || '无备注')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Text(item.name)
          .fontSize(11)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)

      // 金额
      Text(item.isIncome ? `+${item.price.toFixed(2)}` : `-${item.price.toFixed(2)}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.isIncome ? '#fff8a402' : '#ffbe2727')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .borderRadius(isLast ? { bottomLeft: 10, bottomRight: 10 } : 0)
  }

  formatDateDisplay(dateStr: string): string {
    let formatted = dateStr.replace(/-/g, '.')
    const parts = formatted.split('.')
    if (parts.length === 3) {
      return `${parts[0]}年${parseInt(parts[1])}月${parseInt(parts[2])}日`
    }
    return dateStr
  }

  @Builder
  CardPage() {
    Column() {
      TopBack({ title: '账本' })
      Column({ space: 8 }) {
        if (this.showBudgetInput) {
          // 显示输入框
          Row() {
            TextInput({ placeholder: '请输入预算', text: this.tempBudget })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.tempBudget = value
              })
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#F5F0EA')
              .borderRadius(8)
              .padding({ left: 12, right: 12 })

            Button('确定')
              .onClick(() => this.confirmBudget())
              .backgroundColor('#E68A2E')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .margin({ left: 8 })
              .height(40)

            Button('取消')
              .onClick(() => this.cancelBudget())
              .backgroundColor('#999999')
              .fontColor('#FFFFFF')
              .borderRadius(8)
              .margin({ left: 8 })
              .height(40)
          }
          .width('100%')
          .margin({ bottom: 5 })
        } else {
          // 显示预算文字（可点击编辑）
          Row() {
            Text('本月预算  ')
              .fontSize(18)
              .fontColor('#000')
            Text(this.PlanExpense + '￥')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E68A2E')
            Text(' ✎')
              .fontSize(16)
              .fontColor('#999999')
          }
          .onClick(() => {
            this.editBudget()
          })
          .margin({ bottom: 5 })
        }

        Text(`已消费  ${this.totalExpense.toFixed(2)}￥`)
          .fontSize(16)
          .fontColor('#ffbe2727')
        Text(`剩余额度  ${this.rivalExpense.toFixed(2)}￥`)
          .fontSize(16)
          .fontColor('#fff8a402')

        Button('记录')
          .width('60%')
          .height(35)
          .backgroundColor('#FF9907')
          .opacity(0.8)
          .fontColor('#fff')
          .borderRadius(20)
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Two_KeepAccounts' })
          })
      }
      .width('90%')
      .padding(15)
      .borderRadius(10)
      .shadow({ radius: 3, color: '#00000010', offsetY: 2 })
    }
    .width('100%')
    .backgroundColor('#fff')
    .padding({ bottom: 10 })
    .border({ width: 2, color: '#FFE0B2' })
    .borderRadius(18)
  }

  ComputeBill() {
    let sum = 0;
    this.listData.forEach((item: Bill) => {
      if (!item.isIncome) {
        sum += parseFloat(item.price.toString());
      }
    });
    this.totalExpense = sum;
    this.rivalExpense = this.PlanExpense - this.totalExpense;
  }

  deleteItem(index: number) {
    let newList = [...this.listData]
    newList.splice(index, 1)
    this.listData = newList
    this.processData()
    let jsonStr = JSON.stringify(newList)
    kvStoreUtils.putData('keepAccountsKey', jsonStr)
  }

  onPageShow(): void {
    this.getData((success: boolean, data: string) => {
      if (success && data) {
        console.log('获取到的数据:', data)
        this.listData = JSON.parse(data) as Bill[]
        this.processData()
      } else {
        this.listData = []
        this.processData()
      }
    })
  }

  getData(result: (success: boolean, data: string) => void) {
    kvStoreUtils.getData('keepAccountsKey', (data: boolean | string | number | Uint8Array) => {
      if (data) {
        result(true, data as string)
      } else {
        result(false, '')
      }
    }, (e: Error) => {
      result(false, '')
    })
  }

  getImageResource(imageName: string): Resource {
    switch (imageName) {
      case 'cy': return $r('app.media.cy')
      case 'gw': return $r('app.media.gw')
      case 'ryp': return $r('app.media.ryp')
      case 'jt': return $r('app.media.jt')
      case 'gz': return $r('app.media.gz')
      case 'jz': return $r('app.media.jz')
      case 'lc': return $r('app.media.lc')
      case 'qt': return $r('app.media.qt')
      default: return $r('app.media.qt')
    }
  }
}