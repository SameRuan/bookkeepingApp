import { promptAction, router } from '@kit.ArkUI';
import { TopBack } from '../components/top';
import { Bill } from './Two_KeepAccounts';
import { HttpUtil, BillDTO } from '../utils/HttpUtil';

interface DayData {
  date: string;
  bills: Bill[];
  expense: number;
  income: number;
}
/*
 * 账本页面
 * */
@Entry
@Component
export struct Index_ShowAccounts {
  @State listData: Bill[] = []
  @State dayDataList: DayData[] = []
  @State PlanExpense: number = 1800
  @State totalExpense: number = 0
  @State rivalExpense: number = 1800
  @State showBudgetInput: boolean = false
  @State tempBudget: string = ''

  async aboutToAppear() {
    this.loadBudget()
    await this.loadBillsFromServer()
  }

  async onPageShow() {
    await this.loadBillsFromServer()
  }

  async loadBillsFromServer() {
    try {
      const res = await HttpUtil.get<BillDTO[]>('/api/bills')
      if (res.code === 200) {
        const rawList: BillDTO[] = res.data;
        const mapped: Bill[] = [];
        for (let i = 0; i < rawList.length; i++) {
          const item = rawList[i];
          const bill: Bill = {
            text: item.text,
            name: item.name,
            price: Number(item.price),
            imageName: item.imageName === undefined ? 'qt' : item.imageName,
            isIncome: item.isIncome === 1,
            date: (item.date === undefined ? '' : item.date).replace(/-/g, '.'),
            createTime: item.createTime
          };
          mapped.push(bill);
        }
        this.listData = mapped;
        this.processData();
      }
    } catch (err) {
      console.error('加载账单失败:', JSON.stringify(err))
    }
  }

  processData() {
    const groups = new Map<string, Bill[]>()
    const expenseMap = new Map<string, number>()
    const incomeMap = new Map<string, number>()

    this.listData.forEach((item: Bill) => {
      const date = item.date
      if (!groups.has(date)) {
        groups.set(date, [])
        expenseMap.set(date, 0)
        incomeMap.set(date, 0)
      }
      groups.get(date)!.push(item)

      if (item.isIncome) {
        incomeMap.set(date, (incomeMap.get(date) || 0) + item.price)
      } else {
        expenseMap.set(date, (expenseMap.get(date) || 0) + item.price)
      }
    })

    const sortedDates = Array.from(groups.keys()).sort((a: string, b: string) => b.localeCompare(a))
    const dayDataList: DayData[] = []

    sortedDates.forEach((date: string) => {
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

  saveBudget() {
    AppStorage.setOrCreate('monthlyBudget', this.PlanExpense)
  }

  editBudget() {
    this.tempBudget = this.PlanExpense.toString()
    this.showBudgetInput = true
  }

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

  cancelBudget() {
    this.showBudgetInput = false
  }

  // 从 "2026-10-15 17:34:19" 提取 "17:34"
  formatTime(createTime?: string): string {
    if (!createTime) return ''
    const parts = createTime.split(' ')
    if (parts.length === 2) {
      const timeParts = parts[1].split(':')
      if (timeParts.length >= 2) {
        return `${timeParts[0]}:${timeParts[1]}`
      }
    }
    return ''
  }

  build() {
    Column({ space: 5 }) {
      this.CardPage()
      this.ListPage()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF')
  }

  @Builder
  ListPage() {
    List({ space: 12 }) {
      ForEach(this.dayDataList, (dayData: DayData) => {
        ListItem() {
          Column() {
            this.DateHeader(dayData)
            this.DayBillsList(dayData.bills)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
          .border({ width: 1.5, color: '#FFD59A' })
          .shadow({ radius: 6, color: '#FF99071A', offsetY: 2 })
        }
      }, (dayData: DayData) => dayData.date)
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ left: 12, right: 12, top: 8 })
  }

  @Builder
  DateHeader(dayData: DayData) {
    Row() {
      Row({ space: 6 }) {
        // 主题色小圆点
        Column()
          .width(6)
          .height(6)
          .borderRadius(3)
          .backgroundColor('#FF9907')
        Text(this.formatDateDisplay(dayData.date))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#5C3B1F')
      }

      Blank()

      Text(`支出 ¥${dayData.expense.toFixed(2)}`)
        .fontSize(11)
        .fontColor('#E64A19')
      Text(`  收入 ¥${dayData.income.toFixed(2)}`)
        .fontSize(11)
        .fontColor('#F5A623')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 10 })
    .backgroundColor('#FFF9EE')
    .borderRadius({ topLeft: 13, topRight: 13 })
  }

  @Builder
  DayBillsList(bills: Bill[]) {
    Column() {
      ForEach(bills, (item: Bill, index: number) => {
        this.BillItem(item, index === bills.length - 1)
        if (index < bills.length - 1) {
          Divider()
            .color('#FFF0D6')
            .strokeWidth(1)
            .margin({ left: 60, right: 14 })
        }
      }, (item: Bill, index: number) => item.name + (item.createTime || '') + index)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ bottomLeft: 13, bottomRight: 13 })
  }

  @Builder
  BillItem(item: Bill, isLast: boolean) {
    Row() {
      // 圆形图标
      Column() {
        Image(this.getImageResource(item.imageName))
          .width(26)
          .height(26)
          .fillColor('#FF9907')
      }
      .width(38)
      .height(38)
      .backgroundColor('#FFF3DE')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(19)

      // 信息区
      Column({ space: 4 }) {
        Text(item.text || '其他')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Row() {
          Text(item.name)
            .fontSize(11)
            .fontColor('#999999')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (this.formatTime(item.createTime)) {
            Text(this.formatTime(item.createTime))
              .fontSize(10)
              .fontColor('#C4C4C4')
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)

      // 金额
      Text(item.isIncome ? `+${item.price.toFixed(2)}` : `-${item.price.toFixed(2)}`)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.isIncome ? '#F5A623' : '#E64A19')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
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
        sum += Number(item.price)
      }
    });
    this.totalExpense = sum;
    this.rivalExpense = this.PlanExpense - this.totalExpense;
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
