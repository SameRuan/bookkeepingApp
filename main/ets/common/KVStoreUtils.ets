import { distributedKVStore } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'

class KVStoreUtils {

  private kvManager: distributedKVStore.KVManager | undefined = undefined
  private kvStore: distributedKVStore.SingleKVStore | undefined = undefined
  static kvManager: distributedKVStore.KVManager
  // 增加初始化状态标识
  private  isInitialized: boolean = false
  init(context: Context) {
    let config: distributedKVStore.KVManagerConfig = {
      bundleName: 'com.example.jizhangapp',
      context: context
    }
    try {
      this.kvManager = distributedKVStore.createKVManager(config)
    } catch (err) {

    }
  }
  // 初始化方法
  async initKVStore(context: Context): Promise<void> {
    return new Promise((resolve, reject) => {
      const config: distributedKVStore.KVManagerConfig = {
        bundleName: 'com.example.jizhangapp',
        context: context
      };

      try {
        this.kvManager = distributedKVStore.createKVManager(config)
        this.createKVStore().then(() => {
          this.isInitialized = true
          resolve()
        })
      } catch (err) {
        reject(err)
      }
    })
  }
  // 增加状态检查方法
  checkInitialized(): void {
    if (!this.isInitialized) {
      throw new Error('KVStore未初始化')
    }
  }
  //创建KVStore
  createKVStore(): Promise<void> {
    return new Promise((resolve, reject) => {
      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: false,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S3
      };

      this.kvManager?.getKVStore('storeId', options,
        (err, store: distributedKVStore.SingleKVStore) => {
          if (err) {
            reject(new Error(`KVStore创建失败: ${err.code}`)); // 传递错误对象
          } else {
            this.kvStore = store;
            resolve(); // 正确触发Promise完成
          }
        }
      );
    });
  }
  //提交数据
  async putData(key: string, value: string) {
    try {
      this.kvStore = this.kvStore as distributedKVStore.SingleKVStore
      await this.kvStore.put(key, value)
      // this.kvStore.put(key, value, (err) => {
      //   if (err !== undefined) {
      //     console.error(`----==Failed:${err.code},message:${err.message}`)
      //     return;
      //   }
      //   console.info('---===Succeeded')
      // })
    } catch (e) {
      let error = e as BusinessError;
      console.error(`---=====An error:${error.code},message:${error.message}`)
    }
  }
  //获取数据
  getData(key: string, success ?: (data: boolean | string | number | Uint8Array) => void, failure ?: (error: Error) => void) {
    try {
      this.kvStore = this.kvStore as distributedKVStore.SingleKVStore;
      this.kvStore.get(key, (err, data) => {
        if (err != undefined) {
          console.error(`---===Failed to get data. Code:${err.code},message:${err.message}`);
          if (failure) {
            failure(err)
          }
          return;
        }
        console.info(`---===Succeeded in getting data. Data:${data}`);
        if (success) {
          success(data)
        }
      });
    } catch (e) {
      let error = e as BusinessError;
      console.error(`---===Failed to get data. Code:${error.code},message:${error.message}`);
      if (failure) {
        failure(e)
      }
    }
  }
  //删除数据
  deleteData(key: string, success: (result: boolean) => void) {
    this.kvStore?.delete(key, (err) => {
      console.log('---====', JSON.stringify(err))
      success(err === undefined)
    })
  }
}

const kvStoreUtils=new KVStoreUtils()
export {kvStoreUtils}