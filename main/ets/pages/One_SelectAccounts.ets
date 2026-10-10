import { promptAction } from '@kit.ArkUI';
import { kvStoreUtils } from '../common/KVStoreUtils';
import { TopBack } from '../components/top';
import { Bill } from './Two_KeepAccounts';

@Entry
@Component
export struct One {
  // 原始账单数据
  @State private bills: Bill[] = [];
  // 过滤后的账单数据
  @State private filteredBills: Bill[] = [];
  // 查询条件
  @State private startDate: string = '';
  @State private endDate: string = '';
  @State private selectedType: string = 'all'; // all, expense, income
  @State private minAmount: string = '';
  @State private maxAmount: string = '';
  @State private keyword: string = '';

  async aboutToAppear() {
    kvStoreUtils.init(getContext())
    // 关键：先等 KVStore 建好，再去读数据
    try {
      await kvStoreUtils.createKVStore()
    } catch (err) {
      console.error('KVStore初始化失败:', err)
    }
    this.loadBills()
  }

  // 切回页面时也刷一次（如果 One 作为独立路由页会触发；作为子组件不触发也无所谓）
  onPageShow(): void {
    this.loadBills()
  }

  // 统一的读取入口
  loadBills() {
    this.getData((success: boolean, data: string) => {
      if (success && data) {
        console.log('查询页获取到的数据:', data)
        this.bills = JSON.parse(data) as Bill[]
      } else {
        this.bills = []
      }
      this.filterBills()
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

  // 日期归一化：把 2024.10.9 或 2024-10-9 都转成 2024-10-09
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

  // 查询过滤逻辑
  filterBills() {
    let filtered = [...this.bills];

    // 日期范围过滤（归一化后比较）
    if (this.startDate) {
      const start = this.normalizeDate(this.startDate);
      filtered = filtered.filter(item => this.normalizeDate(item.date) >= start);
    }
    if (this.endDate) {
      const end = this.normalizeDate(this.endDate);
      filtered = filtered.filter(item => this.normalizeDate(item.date) <= end);
    }

    // 收支类型过滤
    if (this.selectedType === 'expense') {
      filtered = filtered.filter(item => !item.isIncome);
    } else if (this.selectedType === 'income') {
      filtered = filtered.filter(item => item.isIncome);
    }

    // 金额区间过滤
    const min = this.minAmount !== '' ? parseFloat(this.minAmount) : null;
    const max = this.maxAmount !== '' ? parseFloat(this.maxAmount) : null;
    if (min !== null && !isNaN(min)) {
      filtered = filtered.filter(item => Number(item.price) >= min);
    }
    if (max !== null && !isNaN(max)) {
      filtered = filtered.filter(item => Number(item.price) <= max);
    }

    // 关键词过滤
    if (this.keyword && this.keyword.trim() !== '') {
      const kw = this.keyword.trim().toLowerCase();
      filtered = filtered.filter(item =>
      (item.text && item.text.toLowerCase().includes(kw)) ||
        (item.name && item.name.toLowerCase().includes(kw))
      );
    }

    this.filteredBills = [...filtered];
    console.log('过滤后数据条数:', this.filteredBills.length);
  }

  // 显示日期选择器
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

  // 重置所有查询条件
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

  // 格式化金额
  formatAmount(item: Bill): string {
    const price = Number(item.price);
    if (item.isIncome) {
      return `+${price.toFixed(2)}`;
    } else {
      return `-${price.toFixed(2)}`;
    }
  }

  // 格式化日期 (支持 2024.10.9 和 2024-10-09 -> 2024.10.9)
  formatDate(dateStr: string): string {
    const parts = dateStr.split(/[.\-/]/);
    if (parts.length === 3) {
      return `${parts[0]}.${parseInt(parts[1])}.${parseInt(parts[2])}`;
    }
    return dateStr;
  }

  // 获取金额颜色
  getAmountColor(item: Bill): ResourceColor {
    return item.isIncome ? '#4CAF50' : '#FF4D4F';
  }

  // 收支类型选择
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

  // 日期 + 金额 + 关键词
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
          // 开始日期
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
          // 结束日期
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
            this.filterBills();
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
            this.filterBills();
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
          this.filterBills();
        })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(16)
    .margin({ bottom: 12 })
  }

  // 查询和重置按钮
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

  // 表格表头
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

  // 账单列表
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

  // 统计条数
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

  // 计算总计金额
  calculateTotal(): number {
    let total = 0;
    this.filteredBills.forEach(item => {
      const price = Number(item.price);
      if (item.isIncome) {
        total += price;
      } else {
        total -= price;
      }
    });
    return total;
  }

  // 主界面
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