import {NativeModules} from 'react-native';

export class AdaptValue {
  address: string;

  constructor(address: string) {
    this.address = address;
  }

  async Visualize(): Promise<string> {
    return await AdaptEnvironment.adapt.AV_Visualize(this.address);
  }
}

export class AdaptEnvironment {
  static adapt?: any = undefined;

  static Check() {
    if (this.adapt === undefined) {
      throw new Error('AdaptEnvironment not initialized');
    }
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  public static Initialize(test_mode: boolean): boolean {
    throw new Error('Sync mode not supported on React Native');
  }

  public static async InitializeAsync(test_mode: boolean): Promise<boolean> {
    // if (this.adapt !== undefined) {
    //   throw new Error('AdaptEnvironment already initialized');
    // }
    this.adapt = NativeModules.AdaptWrapper;
    return await this.adapt.AE_Initialize(test_mode);
  }

  public static async SystemTime(): Promise<AdaptValue> {
    this.Check();
    return new AdaptValue(await this.adapt.AE_SystemTime());
  }
}
