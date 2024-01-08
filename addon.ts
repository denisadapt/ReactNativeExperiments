import {NativeModules} from 'react-native';

declare type AdaptValueKey = {
  address: string;
  _type: 'AdaptValue';
};

export class AdaptValue {
  value: AdaptValueKey;
  address: string;

  constructor(address: string | AdaptValueKey) {
    console.log('AdaptValue constructor ', address);
    if (typeof address === 'string') {
      this.address = address;
      this.value = {
        address: address,
        _type: 'AdaptValue',
      };
    } else {
      this.address = address.address;
      this.value = address;
    }
  }

  Visualize(): string {
    return AdaptEnvironment.adapt.AV_Visualize(this.value);
  }

  Destroy(): void {
    AdaptEnvironment.adapt.AV_Destroy(this.value);
  }

  Serialize(): Buffer {
    return AdaptEnvironment.adapt.AV_Serialize(this.value);
  }

  GetHash(): AdaptValue {
    return AdaptEnvironment.adapt.AV_GetHash(this.value);
  }

  Reduce(reducer: AdaptValue): AdaptValue {
    return AdaptEnvironment.adapt.AV_Reduce(this.value, reducer.value);
  }

  Mutate(reducer: AdaptValue, product: AdaptValue): AdaptValue {
    return AdaptEnvironment.adapt.AV_Mutate(
      this.value,
      reducer.value,
      product.value,
    );
  }

  GetPacket(): AdaptPacketContext {
    return new AdaptPacketContext(
      AdaptEnvironment.adapt.AV_GetPacket(this.value),
    );
  }

  GetNumber(): number {
    return AdaptEnvironment.adapt.AV_GetNumber(this.value);
  }

  GetBoolean(): boolean {
    return AdaptEnvironment.adapt.AV_GetBoolean(this.value);
  }

  GetBinary(): Buffer {
    return AdaptEnvironment.adapt.AV_GetBinary(this.value);
  }

  IsNil(): boolean {
    return AdaptEnvironment.adapt.AV_IsNil(this.value);
  }

  Equals(other: AdaptValue): boolean {
    return AdaptEnvironment.adapt.AV_Equals(this.value, other.value);
  }

  Less(other: AdaptValue): boolean {
    return AdaptEnvironment.adapt.AV_Less(this.value, other.value);
  }

  static FromNumber(value: number): AdaptValue {
    return new AdaptValue(AdaptEnvironment.adapt.AV_FromNumber(value));
  }

  static FromBoolean(value: boolean): AdaptValue {
    return new AdaptValue(AdaptEnvironment.adapt.AV_FromBoolean(value));
  }

  static FromString(value: string): AdaptValue {
    return new AdaptValue(AdaptEnvironment.adapt.AV_FromString(value));
  }
}

export class AdaptPacketContext {
  address: string;

  constructor(address: string) {
    this.address = address;
  }

  static LoadFromFile(path: string): AdaptPacketContext {
    return new AdaptPacketContext(
      AdaptEnvironment.adapt.APC_LoadFromFile(path),
    );
  }

  static LoadFromContents(contents: Buffer): AdaptPacketContext {
    return new AdaptPacketContext(
      AdaptEnvironment.adapt.APC_LoadFromContents(contents),
    );
  }

  Destroy(): void {
    AdaptEnvironment.adapt.APC_Destroy(this.address);
  }

  ParseValue(value: AdaptValue): AdaptValue {
    return new AdaptValue(
      AdaptEnvironment.adapt.APC_ParseValue(this.address, value.value),
    );
  }

  ParseValueFromJSON(json: string): AdaptValue {
    return new AdaptValue(
      AdaptEnvironment.adapt.APC_ParseValueFromJSON(this.address, json),
    );
  }

  CreateDictionary(): AdaptValue {
    return new AdaptValue(
      AdaptEnvironment.adapt.APC_CreateDictionary(this.address),
    );
  }

  NewBinaryFromHex(hex: string): AdaptValue {
    return new AdaptValue(
      AdaptEnvironment.adapt.APC_NewBinaryFromHex(this.address, hex),
    );
  }

  NewBinaryFromBuffer(buffer: Buffer): AdaptValue {
    return new AdaptValue(
      AdaptEnvironment.adapt.APC_NewBinaryFromBuffer(this.address, buffer),
    );
  }
}

export class AdaptEnvironment {
  static adapt?: any = undefined;

  static Check() {
    if (this.adapt === undefined) {
      throw new Error('AdaptEnvironment not initialized');
    }
  }

  public static Initialize(test_mode: boolean): boolean {
    this.adapt = NativeModules.AdaptWrapperNative;
    return this.adapt.AE_Initialize(test_mode);
  }

  public static async InitializeAsync(test_mode: boolean): Promise<boolean> {
    // if (this.adapt !== undefined) {
    //   throw new Error('AdaptEnvironment already initialized');
    // }
    this.adapt = NativeModules.AdaptWrapperNative;
    return this.adapt.AE_Initialize(test_mode);
  }

  public static SystemTime(): AdaptValue {
    this.Check();
    return new AdaptValue(this.adapt.AE_SystemTime());
  }
}
