import { promptAction } from '@kit.ArkUI';
import { KeepAccountsModel, TopBack } from '../components/top';
import { HttpUtil, AddBillData, AddBillRequest } from '../utils/HttpUtil';

/*
 * 新增账单-记一笔
 * */
export interface Bill {
  text: string,
  name: string,
  price: number,
  imageName: string,
  isIncome: boolean,
  date: string,
  createTime?: string
}

@Entry
@Component
export struct Two {

  expensesList: KeepAccountsModel[] = [
    { text: '吃', imageName: 'cy', icon: $r('app.media.cy') },
    { text: '穿', imageName: 'gw', icon: $r('app.media.gw') },
    { text: '住', imageName: 'ryp', icon: $r('app.media.ryp') },
    { text: '行', imageName: 'jt', icon: $r('app.media.jt') }
  ]

  incomeList: KeepAccountsModel[] = [
    { text: '工资', imageName: 'gz', icon: $r('app.media.gz') },
    { text: '兼职', imageName: 'jz', icon: $r('app.media.jz') },
    { text: '窝囊费', imageName: 'lc', icon: $r('app.media.lc') },
    { text: '其他', imageName: 'qt', icon: $r('app.media.qt') }
  ]

  @State selectedExpensesIndex: number = -1
  @State selectedIncomeIndex: number = -1
  @State money: number = 0
  @State notes: string = ''

  build() {
    Column({ space: 0 }) {
      TopBack({ title: '记一笔' })

      Column({ space: 0 }) {
        // 支出类型
        Column({ space: 10 }) {
          Text('支出')
            .fontSize(16)
            .fontWeight(500)
            .width('100%')
            .padding({ left: 20 })

          Row({ space: 15 }) {
            ForEach(this.expensesList, (item: KeepAccountsModel, index: number) => {
              Column({ space: 5 }) {
                Column() {
                  Image(item.icon)
                    .width(25)
                    .height(25)
                    .fillColor('#FF9800')
                }
                .width(45)
                .height(45)
                .backgroundColor('#FFF7ED')
                .borderRadius(22.5)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)

                Text(item.text)
                  .fontSize(12)
                  .fontColor('#333333')
              }
              .width('22%')
              .padding({ top: 12, bottom: 12 })
              .backgroundColor(this.selectedExpensesIndex === index ? '#FFFFE0B2' : 'white')
              .borderRadius(10)
              .shadow({ radius: 6, color: 'rgba(0,0,0,0.4)', offsetY: 2 })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.selectedExpensesIndex = index
                this.selectedIncomeIndex = -1
              })
            })
          }
          .width('95%')
          .justifyContent(FlexAlign.SpaceAround)
          .margin({ left: '2.5%' })
        }
        .width('100%')
        .margin({ top: 30 })

        // 收入类型
        Column({ space: 10 }) {
          Text('收入')
            .fontSize(16)
            .fontWeight(500)
            .width('100%')
            .padding({ left: 20 })

          Row({ space: 15 }) {
            ForEach(this.incomeList, (item: KeepAccountsModel, index: number) => {
              Column({ space: 5 }) {
                Column() {
                  Image(item.icon)
                    .width(25)
                    .height(25)
                    .fillColor('#FF9800')
                }
                .width(45)
                .height(45)
                .backgroundColor('#FFF7ED')
                .borderRadius(22.5)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)

                Text(item.text)
                  .fontSize(12)
                  .fontColor('#333333')
              }
              .width('22%')
              .padding({ top: 12, bottom: 12 })
              .backgroundColor(this.selectedIncomeIndex === index ? '#FFFFE0B2' : 'white')
              .borderRadius(10)
              .shadow({ radius: 6, color: 'rgba(0,0,0,0.4)', offsetY: 2 })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.selectedIncomeIndex = index
                this.selectedExpensesIndex = -1
              })
            })
          }
          .width('95%')
          .justifyContent(FlexAlign.SpaceAround)
          .margin({ left: '2.5%' })
        }
        .width('100%')
        .margin({ top: 30 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .flexGrow(1)

      Column({ space: 15 }) {
        Column() {
          TextInput({ placeholder: '金额', text: this.money === 0 ? '' : this.money.toString() })
            .width('100%')
            .height(45)
            .border({ width: 1, color: '#E0E0E0', radius: 16 })
            .textAlign(TextAlign.Center)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#FFFFFF')
            .type(InputType.Number)
            .onChange((value: string) => {
              this.money = Number(value)
            })
        }
        .width('100%')
        .padding({ left: 60, right: 60 })

        Column() {
          TextInput({ placeholder: '备注', text: this.notes })
            .width('100%')
            .height(45)
            .border({ width: 1, color: '#E0E0E0', radius: 16 })
            .textAlign(TextAlign.Center)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => {
              this.notes = value
            })
        }
        .width('100%')
        .padding({ left: 60, right: 60 })

        Column() {
          Button('保存')
            .width('80%')
            .margin({ top: 20 })
            .onClick(() => {
              this.save()
            })
            .opacity(0.8)
            .backgroundColor('#FF9907')
        }
        .width('100%')
        .padding({ left: 60, right: 60 })
      }
      .width('100%')
      .padding({ top: 20, bottom: 30 })
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  save() {
    if (this.selectedExpensesIndex < 0 && this.selectedIncomeIndex < 0) {
      promptAction.showToast({ message: '请选择记账类型' })
      return
    }
    if (!this.money || this.money <= 0) {
      promptAction.showToast({ message: '请输入正确的金额' })
      return
    }
    if (!this.notes || this.notes.length <= 0) {
      promptAction.showToast({ message: '请输入备注' })
      return
    }
    this.putData()
  }

  async putData() {
    let imageName = ''
    let text = ''
    if (this.selectedExpensesIndex >= 0) {
      imageName = this.expensesList[this.selectedExpensesIndex].imageName
      text = this.expensesList[this.selectedExpensesIndex].text
    } else if (this.selectedIncomeIndex >= 0) {
      imageName = this.incomeList[this.selectedIncomeIndex].imageName
      text = this.incomeList[this.selectedIncomeIndex].text
    }

    const d = new Date()
    const mm = (d.getMonth() + 1).toString().padStart(2, '0')
    const dd = d.getDate().toString().padStart(2, '0')
    const dateStr = `${d.getFullYear()}-${mm}-${dd}`

    try {
      const reqBody: AddBillRequest = {
        text: text,
        name: this.notes,
        price: this.money,
        isIncome: this.selectedIncomeIndex >= 0,
        imageName: imageName,
        date: dateStr
      }
      const res = await HttpUtil.post<AddBillData>('/api/bills', reqBody)
      if (res.code === 200) {
        promptAction.showToast({ message: '记账成功' })
        this.getUIContext().getRouter().pushUrl({ url: 'pages/EntryPage' })
      } else {
        promptAction.showToast({ message: res.msg || '保存失败' })
      }
    } catch (err) {
      console.error('保存失败:', JSON.stringify(err))
      promptAction.showToast({ message: '网络请求失败' })
    }
  }
}
