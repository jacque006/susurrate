import { createPublicClient, createWalletClient, getContract, http, type GetContractReturnType, type Hex, type PublicClient, type WalletClient } from 'viem';
import abi from '../../contracts/out/Counter.abi.json' with { type: 'json' };
import { privateKeyToAccount, type Address } from 'viem/accounts';

export class CounterCountract {
    private contract: GetContractReturnType<typeof abi, PublicClient | WalletClient>;
    
    constructor(rpcUrl: string, contractAddress: Address, privateKey: Hex) {
        const publicClient = createPublicClient({
            transport: http(rpcUrl),
        });

        const account = privateKeyToAccount(privateKey);
        
        const walletClient = createWalletClient({ 
            account, 
            transport: http(rpcUrl),
        });
        
        this.contract = getContract({
            address: contractAddress,
            abi,
            client: {
                public: publicClient,
                wallet: walletClient,
            },
        });    
    }

    public async getValue(): Promise<String> {
        if (!this.contract.read.get) {
            throw new Error('missing contract.read.get');
        }
        const res = await this.contract.read.get();
        return res as String;
    }

    public async increment(): Promise<void> {
        if (!this.contract.write.increment) {
            throw new Error('missing contract.write.increment');
        }
        const _res = await this.contract.write?.increment();
    }
}
