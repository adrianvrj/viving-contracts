use starknet::ContractAddress;

#[starknet::interface]
pub trait IVivi<TContractState> {
    fn get_health_points(self: @TContractState) -> felt252;
    fn get_room(self: @TContractState) -> felt252;
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn next_room(ref self: TContractState, damage: felt252, heal: felt252);
}

#[starknet::contract]
mod Vivi {
    use starknet::get_caller_address;
use starknet::ContractAddress;
use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        health_points: felt252,
        room: felt252,
        owner: ContractAddress,
    }

    #[abi(embed_v0)]
    impl ViviImpl of super::IVivi<ContractState> {
        fn get_health_points(self: @ContractState) -> felt252 {
            self.health_points.read()
        }
        fn get_room(self: @ContractState) -> felt252 {
            self.room.read()
        }
        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
        fn next_room(ref self: ContractState, damage: felt252, heal: felt252) {
            assert(self.owner.read() == get_caller_address(), 'Not owner');
            self.room.write(self.room.read() + 1);
            self.health_points.write(self.health_points.read() - damage);
            self.health_points.write(self.health_points.read() + heal);
        }
    }
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.health_points.write(10);
        self.room.write(0);
        self.owner.write(owner);
    }
}
