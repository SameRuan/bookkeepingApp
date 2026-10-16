import { promptAction } from '@kit.ArkUI';
import { TopBack } from '../components/top';
import { Bill } from './Two_KeepAccounts';
import { HttpUtil, BillDTO } from '../utils/HttpUtil';

/*
 * 查询页面
 * */
@Entry
@Component
export struct One {
  @State private bills: Bill[] = [];
  @State private filteredBills: Bill[] = [];
  @State private startDate: string = '';
  @State private endDate: string = '';
  @State private selectedType: string = 'all';
  @State private minAmount: string = '';
  @State private maxAmount: string = '';
  @State private keyword: string = '';

  async aboutToAppear() {
    await this.filterBills()
  }

  onPageShow(): void {
    this.filterBills()
  }

  normalizeDate(dateStr: string): string {
    if (!dateStr) return ''
    const parts = dateStr.split(/[.\-/]/)
    if (parts.length === 3) {
      const y = parts[0]
      const m = parts[1].padStart(2, '0')
      const d = parts[2].padStart(2, '0')
      return `${y}-${m}-${d}`
    }
    return dateStr
  }

  async filterBills() {
    const params: Record<string, string> = {}
    if (this.startDate) params.startDate = this.normalizeDate(this.startDate)
    if (this.endDate) params.endDate = this.normalizeDate(this.endDate)
    if (this.selectedType && this.selectedType !== 'all') params.type = this.selectedType
    if (this.minAmount) params.minAmount = this.minAmount
    if (this.maxAmount) params.maxAmount = this.maxAmount
    if (this.keyword) params.keyword = this.keyword

    try {
      const res = await HttpUtil.get<BillDTO[]>('/api/bills/query', params)
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
        this.filteredBills = mapped;
      } else {
        promptAction.showToast({ message: res.msg || '查询失败' })
      }
    } catch (err) {
      console.error('查询失败:', JSON.stringify(err))
      promptAction.showToast({ message: '网络请求失败' })
    }
  }

  showDatePicker(isStart: boolean) {
    let currentDate = new Date();
    if (isStart && this.startDate) {
      currentDate = new Date(this.normalizeDate(this.startDate));
    } else if (!isStart && this.endDate) {
      currentDate = new Date(this.normalizeDate(this.endDate));
    }
    DatePickerDialog.show({
      start: new Date('2000-1-1'),
      end: new Date('2099-12-31'),
      selected: currentDate,
      onAccept: (value: DatePickerResult) => {
        const year = value.year;
        const month = (value.month! + 1).toString().padStart(2, '0');
        const day = value.day!.toString().padStart(2, '0');
        const dateStr = `${year}-${month}-${day}`;
        if (isStart) {
          this.startDate = dateStr;
          if (this.endDate && this.normalizeDate(this.endDate) < this.normalizeDate(this.startDate)) {
            this.endDate = '';
          }
        } else {
          this.endDate = dateStr;
          if (this.startDate && this.normalizeDate(this.endDate) < this.normalizeDate(this.startDate)) {
            this.endDate = '';
            promptAction.showToast({ message: '结束日期不能早于开始日期' });
          }
        }
        this.filterBills();
      }
    });
  }

  resetFilters() {
    this.startDate = '';
    this.endDate = '';
    this.selectedType = 'all';
    this.minAmount = '';
    this.maxAmount = '';
    this.keyword = '';
    this.filterBills();
    promptAction.showToast({ message: '已重置查询条件' });
  }

  formatAmount(item: Bill): string {
    const price = Number(item.price);
    if (item.isIncome) {
      return `+${price.toFixed(2)}`;
    } else {
      return `-${price.toFixed(2)}`;
    }
  }

  formatDate(dateStr: string): string {
    const parts = dateStr.split(/[.\-/]/);
    if (parts.length === 3) {
      return `${parts[0]}.${parseInt(parts[1])}.${parseInt(parts[2])}`;
    }
    return dateStr;
  }

  getAmountColor(item: Bill): ResourceColor {
    return item.isIncome ? '#4CAF50' : '#FF4D4F';
  }

  @Builder
  buildIncomeExpenseType() {
    Column() {
      Text(' 收支类型')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5C3B1F')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      Row() {
        this.buildTypeButton('全部账单', 'all')
        this.buildTypeButton('支出', 'expense')
        this.buildTypeButton('收入', 'income')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(16)
    .margin({ bottom: 12 })
  }

  @Builder
  buildTypeButton(label: string, type: string) {
    Button(label)
      .fontSize(14)
      .height(40)
      .layoutWeight(1)
      .backgroundColor(this.selectedType === type ? '#FF9907' : '#F5F0EA')
      .fontColor(this.selectedType === type ? '#FFFFFF' : '#5C3B1F')
      .borderRadius(20)
      .margin({ left: 4, right: 4 })
      .onClick(() => {
        this.selectedType = type;
        this.filterBills();
      })
  }

  @Builder
  buildAmountRange() {
    Column() {
      Column() {
        Text(' 日期范围')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5C3B1F')
          .margin({ bottom: 12 })
          .alignSelf(ItemAlign.Start)
        Row() {
          Column() {
            Row() {
              Text(this.startDate || '请选择')
                .fontSize(14)
                .fontColor(this.startDate ? '#333333' : '#999999')
                .layoutWeight(1)
              Image($r('app.media.data_riqi'))
                .width(18)
                .height(18)
            }
            .width('100%')
            .height(40)
            .backgroundColor('#F5F0EA')
            .borderRadius(8)
            .padding({ left: 12, right: 8 })
            .onClick(() => this.showDatePicker(true))
          }
          .layoutWeight(1)
          Text('至')
            .fontSize(14)
            .fontColor('#5C3B1F')
            .margin({ left: 8, right: 8 })
          Column() {
            Row() {
              Text(this.endDate || '请选择')
                .fontSize(14)
                .fontColor(this.endDate ? '#333333' : '#999999')
                .layoutWeight(1)
              Image($r('app.media.data_riqi'))
                .width(18)
                .height(18)
            }
            .width('100%')
            .height(40)
            .backgroundColor('#F5F0EA')
            .borderRadius(8)
            .padding({ left: 12, right: 8 })
            .onClick(() => this.showDatePicker(false))
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ bottom: 12 })

      Text(' 金额范围')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5C3B1F')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      Row() {
        TextInput({ placeholder: '最低金额', text: this.minAmount })
          .fontSize(14)
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#F5F0EA')
          .borderRadius(12)
          .type(InputType.Number)
          .textAlign(TextAlign.Center)
          .onChange((value: string) => {
            this.minAmount = value;
          })
        Text('-')
          .fontSize(18)
          .fontColor('#5C3B1F')
          .margin({ left: 12, right: 12 })
        TextInput({ placeholder: '最高金额', text: this.maxAmount })
          .fontSize(14)
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#F5F0EA')
          .borderRadius(12)
          .type(InputType.Number)
          .textAlign(TextAlign.Center)
          .onChange((value: string) => {
            this.maxAmount = value;
          })
      }
      .width('100%')
      Text('单位：元')
        .fontSize(11)
        .fontColor('#999999')
        .margin({ top: 8 })
        .alignSelf(ItemAlign.End)
      Text('关键词搜索')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#5C3B1F')
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      TextInput({ placeholder: '搜索项目或备注', text: this.keyword })
        .fontSize(14)
        .height(44)
        .width('100%')
        .backgroundColor('#F5F0EA')
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.keyword = value;
        })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(16)
    .margin({ bottom: 12 })
  }

  @Builder
  buildQueryButton() {
    Row() {
      Button('查询')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .height(30)
        .layoutWeight(1)
        .backgroundColor('#FF9907')
        .fontColor('#FFFFFF')
        .borderRadius(24)
        .onClick(() => {
          this.filterBills();
          promptAction.showToast({ message: `找到 ${this.filteredBills.length} 条记录` });
        })
      Button('重置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .height(30)
        .layoutWeight(1)
        .backgroundColor('#F5F0EA')
        .fontColor('#5C3B1F')
        .borderRadius(24)
        .margin({ left: 12 })
        .onClick(() => this.resetFilters())
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  buildTableHeader() {
    Row() {
      Text('项目')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5C3B1F')
        .layoutWeight(1.5)
      Text('备注')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5C3B1F')
        .layoutWeight(1.5)
      Text('金额')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5C3B1F')
        .layoutWeight(1.2)
        .textAlign(TextAlign.End)
      Text('日期')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5C3B1F')
        .layoutWeight(1.2)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 14, bottom: 10 })
    .borderRadius({ topLeft: 12, topRight: 12 })
    .backgroundColor('#FFF4E8')
  }

  @Builder
  buildDataList() {
    Column() {
      if (this.filteredBills.length === 0) {
        Column() {
          Image($r('app.media.qt'))
            .width(60)
            .height(60)
            .opacity(0.5)
            .margin({ bottom: 12 })
          Text('暂无账单记录')
            .fontSize(14)
            .fontColor('#999999')
          Text('试试调整筛选条件吧')
            .fontSize(12)
            .fontColor('#CCCCCC')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding(40)
        .alignItems(HorizontalAlign.Center)
      } else {
        ForEach(this.filteredBills, (item: Bill, index: number) => {
          Column() {
            Row() {
              Text(item.name)
                .fontSize(15)
                .fontColor('#333333')
                .layoutWeight(1.5)
                .fontWeight(FontWeight.Medium)
              Text(item.text || '无备注')
                .fontSize(13)
                .fontColor('#666666')
                .layoutWeight(1.5)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(this.formatAmount(item))
                .fontSize(16)
                .fontColor(this.getAmountColor(item))
                .layoutWeight(1.2)
                .textAlign(TextAlign.End)
                .fontWeight(FontWeight.Bold)
              Text(this.formatDate(item.date))
                .fontSize(12)
                .fontColor('#999999')
                .layoutWeight(1.2)
                .textAlign(TextAlign.End)
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 14, bottom: 14 })
          }
          .width('100%')
          .backgroundColor(index % 2 === 0 ? '#FFFFFF' : '#FFF9F0')
          .borderRadius(index === this.filteredBills.length - 1 ? { bottomLeft: 12, bottomRight: 12 } : 0)
        }, (item: Bill, index: number) => item.name + item.date + index)
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  buildTotalCount() {
    Row() {
      Text(`共 ${this.filteredBills.length} 条记录`)
        .fontSize(13)
        .fontColor('#8B5A2B')
      Blank()
      if (this.filteredBills.length > 0) {
        Text(`总计: ${this.calculateTotal().toFixed(2)}元`)
          .fontSize(13)
          .fontColor('#E68A2E')
          .fontWeight(FontWeight.Medium)
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor('#FFF9F0')
    .borderRadius(20)
    .margin({ bottom: 20 })
  }

  calculateTotal(): number {
    let total = 0;
    this.filteredBills.forEach((item: Bill) => {
      const price = Number(item.price);
      if (item.isIncome) {
        total += price;
      } else {
        total -= price;
      }
    });
    return total;
  }

  build() {
    Column() {
      TopBack({ title: '查询' })
      Scroll() {
        Column() {
          this.buildIncomeExpenseType()
          this.buildAmountRange()
          this.buildQueryButton()
          this.buildTableHeader()
          this.buildDataList()
          this.buildTotalCount()
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#FDF7EC')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FDF7EC')
  }
}
