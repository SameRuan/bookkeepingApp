import { router, promptAction } from '@kit.ArkUI';
import { kvStoreUtils } from '../common/KVStoreUtils';
import { KeepAccountsModel, TopBack } from '../components/top';


export interface Bill {
  text: string,//类型
  name: string,//备注
  price: number,//金额
  imageName: string,//类型照片
  isIncome: boolean,//支出/收入
  date:string
}

@Entry
@Component
export struct Two{
  async  aboutToAppear() {
    // 修改后的初始化逻辑
    kvStoreUtils.init(getContext())
    kvStoreUtils.createKVStore().then(() => {
      console.log('KVStore初始化成功')
    }).catch((err: Error) => {
      console.error('KVStore初始化失败:', err)
    })
    this.getData(async(success: boolean, data: string)=>{
      if (success && data) {
        console.log('获取到的数据:', data)
      } else {
        console.log('no')
      }
    })
  }

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
      // 顶部标题栏
      TopBack({title:'记一笔'})

      // 中间主要内容区域 - 使用Flex布局
      Column({ space: 0 }) {
        // 支出类型区域
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
              .shadow({
                radius: 6,
                color: 'rgba(0,0,0,0.4)',
                offsetY: 2
              })
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

        // 收入类型区域
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
              .shadow({
                radius: 6,
                color: 'rgba(0,0,0,0.4)',
                offsetY: 2
              })
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

      // 底部输入区域 - 三个组件格式完全一致
      Column({ space: 15 }) {
        // 金额输入框 - 离左右边框60px，文字居中
        Column() {
          TextInput({ placeholder: '金额', text: this.money.toString() })
            .width('100%')
            .height(45)
            .border({ width: 1, color: '#E0E0E0', radius: 16 })
            .textAlign(TextAlign.Center)
            .padding({ left: 15, right: 15 })
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => {
              this.money = Number(value)
            })
        }

        .width('100%')
        .padding({ left: 60, right: 60 })

        // 备注输入框 - 离左右边框60px，文字居中
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

        // 确定按钮 - 格式与输入框完全一致，只有字体颜色不同
        Column() {
          Button('保存')
            .width('80%')
            .margin({top:20})
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

  /**
   * 数据增删改查
   */
  async  save() {
    if (this.selectedExpensesIndex < 0 && this.selectedIncomeIndex < 0) {
      promptAction.showToast({
        message: '请选择记账类型' })
      return
    }

    if (!this.money || this.notes.length <= 0) {
      promptAction.showToast({
        message: '请输入金额和备注' })
      return
    }
    await this.putData()
  }

  async  putData() {
    this.getData(async (success: boolean, data: string) => {
      if (success) {
        let list: Bill[] = JSON.parse(data) as Bill[]
        let jsonStr = this.handleData(list)
        kvStoreUtils.putData('keepAccountsKey', jsonStr)
        this.getUIContext().getRouter().pushUrl({url:"pages/EntryPage"})
      } else {
        let jsonStr = this.handleData()
        kvStoreUtils.putData('keepAccountsKey', jsonStr)
        this.getUIContext().getRouter().pushUrl({url:"pages/EntryPage"})
      }
    })
  }
  // save() {
  //   if (this.selectedExpensesIndex < 0 && this.selectedIncomeIndex < 0) {
  //     promptAction.showToast({
  //       message: '请选择记账类型' })
  //     return
  //   }
  //
  //   if (this.money.length <= 0 || this.notes.length <= 0) {
  //     promptAction.showToast({
  //       message: '请输入金额和备注' })
  //     return
  //   }
  //
  //   this.putData(() => {
  //     //router.back()不能用
  //     this.getUIContext().getRouter().back()
  //
  //   })
  // }
  //
  // //
  // putData(callBack: () => void) {
  //   this.getData((success: boolean, data: string) => {
  //     if (success) {
  //       let list: Bill[] = JSON.parse(data) as Bill[]
  //       let jsonStr = this.handleData(list)
  //       kvStoreUtils.putData('keepAccountsKey', jsonStr)
  //       callBack()
  //     } else {
  //       let jsonStr = this.handleData()
  //       kvStoreUtils.putData('keepAccountsKey', jsonStr)
  //       callBack()
  //     }
  //   })
  // }

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

  //提交数据：把获得的数据存入账单列表

  handleData(list: Bill[] = []): string {
    let imageName: string = ''
    let text: string = ''
    if (this.selectedExpensesIndex >= 0) {
      imageName = this.expensesList[this.selectedExpensesIndex].imageName
      text = this.expensesList[this.selectedExpensesIndex].text
    } else if (this.selectedIncomeIndex >= 0) {
      imageName = this.incomeList[this.selectedIncomeIndex].imageName
      text = this.incomeList[this.selectedIncomeIndex].text
    }
    const dateNow = new Date()
    let bill: Bill = {
      name: this.notes,
      price: this.money,
      imageName: imageName,  // 存储图片名称
      text: text,
      isIncome: this.selectedIncomeIndex >= 0,
      date:`${dateNow.getFullYear()}.${dateNow.getMonth()+1}.${dateNow.getDate()}`
    }
    list.push(bill)
    let jsonStr = JSON.stringify(list)
    return jsonStr
  }
}