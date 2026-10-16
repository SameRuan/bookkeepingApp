import { TopBack } from '../components/top';
import { HttpUtil,StatisticsData, RatioItem } from '../utils/HttpUtil';

/*
 * 统计页面
 * */
@Entry
@Component
export struct Three {

  @State totalIncome: number = 0;
  @State totalExpense: number = 0;
  @State balance: number = 0;
  @State expenseRatio: RatioItem[] = [];
  @State incomeRatio: RatioItem[] = [];

  async aboutToAppear() {
    await this.loadStatistics()
  }

  onPageShow() {
    this.loadStatistics()
  }

  async loadStatistics() {
    try {
      const res = await HttpUtil.get<StatisticsData>('/api/statistics')
      if (res.code === 200) {
        const d: StatisticsData = res.data;
        this.totalIncome = d.totalIncome || 0
        this.totalExpense = d.totalExpense || 0
        this.balance = d.balance || 0
        this.expenseRatio = d.expenseRatio || []
        this.incomeRatio = d.incomeRatio || []
      }
    } catch (err) {
      console.error('获取统计失败:', JSON.stringify(err))
    }
  }

  build() {
    Column({ space: 0 }) {
      TopBack({ title: '账单统计' })
        .backgroundColor('#FFF9E8')

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
      .padding({ top: 20, bottom: 20, left: 24, right: 20 })
      .backgroundColor('#FFF')
      .margin({ top: 10 })
      .borderRadius(16)
      .shadow({ radius: 8, color: "#0000001A" })

      Column({ space: 8 }) {
        Text('支出分类占比')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
        Row({ space: 60 }) {
          ForEach(this.expenseRatio.filter((_, idx: number) => idx < 2), (item: RatioItem) => {
            Text(`■${item.name} ${item.ratio}%`)
              .fontSize(14)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        Row({ space: 60 }) {
          ForEach(this.expenseRatio.filter((_, idx: number) => idx >= 2), (item: RatioItem) => {
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

      Column({ space: 8 }) {
        Text('收入分类占比')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
        Row({ space: 60 }) {
          ForEach(this.incomeRatio.filter((_, idx: number) => idx < 2), (item: RatioItem) => {
            Text(`■${item.name} ${item.ratio}%`)
              .fontSize(14)
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        Row({ space: 60 }) {
          ForEach(this.incomeRatio.filter((_, idx: number) => idx >= 2), (item: RatioItem) => {
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
}
