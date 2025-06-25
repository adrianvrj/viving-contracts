use starknet::ContractAddress;

#[starknet::interface]
pub trait IViviFactory<TContractState> {
    fn create_vivi(ref self: TContractState, owner: ContractAddress) -> ContractAddress;
    fn get_vivi(self: @TContractState, owner: ContractAddress) -> ContractAddress;
}

#[starknet::contract]
mod ViviFactory {
    use super::*;
    use starknet::ContractAddress;
    use starknet::class_hash::ClassHash;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{syscalls::deploy_syscall};
    use core::option::Option;
    use core::option::Option::{Some, None};

    #[storage]
    struct Storage {
        owner_to_vivi: Map<ContractAddress, Option<ContractAddress>>,
        vivi_class_hash: ClassHash,
    }

    fn zero_address() -> ContractAddress {
        0.try_into().unwrap()
    }

    #[abi(embed_v0)]
    impl ViviFactoryImpl of super::IViviFactory<ContractState> {
        fn create_vivi(ref self: ContractState, owner: ContractAddress) -> ContractAddress {
            let existing = StorageMapReadAccess::read(self.owner_to_vivi.deref(), owner);
            match existing {
                Some(addr) => addr,
                None => {
                    let class_hash = self.vivi_class_hash.read();
                    let calldata = array![owner.into()];
                    let (contract_address, _) = deploy_syscall(
                        class_hash,
                        0, // salt
                        calldata.span(),
                        false // deploy_from_zero
                    ).unwrap();
                    StorageMapWriteAccess::write(self.owner_to_vivi.deref(), owner, Some(contract_address));
                    contract_address
                }
            }
        }

        fn get_vivi(self: @ContractState, owner: ContractAddress) -> ContractAddress {
            match StorageMapReadAccess::read(self.owner_to_vivi.deref(), owner) {
                Some(addr) => addr,
                None => zero_address(),
            }
        }
    }

    #[constructor]
    fn constructor(ref self: ContractState, vivi_class_hash: ClassHash) {
        self.vivi_class_hash.write(vivi_class_hash);
    }
}
