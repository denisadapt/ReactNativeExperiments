import {NativeModules} from 'react-native';

export class AdaptValue {
  address: string;

  constructor(address: string) {
    this.address = address;
  }

  async Visualize(): Promise<string> {
    return await AdaptEnvironment.adapt.AV_Visualize(this.address);
  }

  async Destroy(): Promise<void> {
    await AdaptEnvironment.adapt.AV_Destroy(this.address);
  }

  async Serialize(): Promise<Buffer> {
    return await AdaptEnvironment.adapt.AV_Serialize(this.address);
  }

  async GetHash(): Promise<AdaptValue> {
    return await AdaptEnvironment.adapt.AV_GetHash(this.address);
  }

  async Reduce(reducer: AdaptValue): Promise<AdaptValue> {
    return await AdaptEnvironment.adapt.AV_Reduce(
      this.address,
      reducer.address,
    );
  }

  async Mutate(reducer: AdaptValue, product: AdaptValue): Promise<AdaptValue> {
    return await AdaptEnvironment.adapt.AV_Mutate(
      this.address,
      reducer.address,
      product.address,
    );
  }

  async GetPacket(): Promise<AdaptPacketContext> {
    return new AdaptPacketContext(
      await AdaptEnvironment.adapt.AV_GetPacket(this.address),
    );
  }

  async GetNumber(): Promise<number> {
    return await AdaptEnvironment.adapt.AV_GetNumber(this.address);
  }

  async GetBoolean(): Promise<boolean> {
    return await AdaptEnvironment.adapt.AV_GetBoolean(this.address);
  }

  async GetBinary(): Promise<Buffer> {
    return await AdaptEnvironment.adapt.AV_GetBinary(this.address);
  }

  async IsNil(): Promise<boolean> {
    return await AdaptEnvironment.adapt.AV_IsNil(this.address);
  }

  async Equals(other: AdaptValue): Promise<boolean> {
    return await AdaptEnvironment.adapt.AV_Equals(this.address, other.address);
  }

  async Less(other: AdaptValue): Promise<boolean> {
    return await AdaptEnvironment.adapt.AV_Less(this.address, other.address);
  }

  static async FromNumber(value: number): Promise<AdaptValue> {
    return new AdaptValue(await AdaptEnvironment.adapt.AV_FromNumber(value));
  }

  static async FromBoolean(value: boolean): Promise<AdaptValue> {
    return new AdaptValue(await AdaptEnvironment.adapt.AV_FromBoolean(value));
  }

  static async FromString(value: string): Promise<AdaptValue> {
    return new AdaptValue(await AdaptEnvironment.adapt.AV_FromString(value));
  }
}

export class AdaptPacketContext {
  address: string;

  constructor(address: string) {
    this.address = address;
  }

  static async LoadFromFile(path: string): Promise<AdaptPacketContext> {
    return new AdaptPacketContext(
      await AdaptEnvironment.adapt.APC_LoadFromFile(path),
    );
  }

  static async LoadFromContents(contents: Buffer): Promise<AdaptPacketContext> {
    return new AdaptPacketContext(
      await AdaptEnvironment.adapt.APC_LoadFromContents(contents),
    );
  }

  async Destroy(): Promise<void> {
    await AdaptEnvironment.adapt.APC_Destroy(this.address);
  }

  async ParseValue(value: AdaptValue): Promise<AdaptValue> {
    return new AdaptValue(
      await AdaptEnvironment.adapt.APC_ParseValue(this.address, value.address),
    );
  }

  async ParseValueFromJSON(json: string): Promise<AdaptValue> {
    return new AdaptValue(
      await AdaptEnvironment.adapt.APC_ParseValueFromJSON(this.address, json),
    );
  }

  async CreateDictionary(): Promise<AdaptValue> {
    return new AdaptValue(
      await AdaptEnvironment.adapt.APC_CreateDictionary(this.address),
    );
  }

  async NewBinaryFromHex(hex: string): Promise<AdaptValue> {
    return new AdaptValue(
      await AdaptEnvironment.adapt.APC_NewBinaryFromHex(this.address, hex),
    );
  }

  async NewBinaryFromBuffer(buffer: Buffer): Promise<AdaptValue> {
    return new AdaptValue(
      await AdaptEnvironment.adapt.APC_NewBinaryFromBuffer(
        this.address,
        buffer,
      ),
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
