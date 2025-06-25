# Viving Contracts Documentation

This repository contains the smart contracts for the Viving game, built on Starknet using Cairo. The project consists of two main contracts: `Vivi` (the game character) and `ViviFactory` (the contract factory for creating Vivi instances).

## Contract Overview

### Vivi Contract
The `Vivi` contract represents a game character with health points and room progression mechanics.

**Class Hash:** `0x0291c08d83c574f909ef911e96ee48bc4c461f7df63e300aa53a7ac61f6920c5`

### ViviFactory Contract
The `ViviFactory` contract is responsible for creating and managing Vivi instances for different owners.

**Class Hash:** `0x03ee2cada41d768a803dcfd24fe830559606133f7fcb9b94c951bcc28542ea33`

## Project Structure

```
viving-contracts/
├── viving/                 # Vivi character contract
│   ├── src/
│   │   └── lib.cairo      # Main Vivi contract implementation
│   ├── Scarb.toml         # Project configuration
│   └── snfoundry.toml     # Foundry configuration
├── vivifactory/           # ViviFactory contract
│   ├── src/
│   │   └── lib.cairo      # Main ViviFactory contract implementation
│   ├── Scarb.toml         # Project configuration
│   └── snfoundry.toml     # Foundry configuration
└── README.md              # This documentation
```

## Vivi Contract

### Interface

```cairo
#[starknet::interface]
pub trait IVivi<TContractState> {
    fn get_health_points(self: @TContractState) -> felt252;
    fn get_room(self: @TContractState) -> felt252;
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn next_room(ref self: TContractState, damage: felt252, heal: felt252);
}
```

### Storage

The Vivi contract stores the following state variables:

- `health_points: felt252` - Current health points of the Vivi character
- `room: felt252` - Current room number the character is in
- `owner: ContractAddress` - Address of the character owner

### Functions

#### Constructor
```cairo
fn constructor(ref self: ContractState, owner: ContractAddress)
```
- **Purpose:** Initializes a new Vivi character
- **Parameters:**
  - `owner`: The address that will own this Vivi character
- **Initial State:**
  - Health points: 10
  - Room: 0
  - Owner: Set to the provided address

#### get_health_points
```cairo
fn get_health_points(self: @ContractState) -> felt252
```
- **Purpose:** Returns the current health points of the Vivi character
- **Returns:** Current health points as a felt252
- **Access:** Public (read-only)

#### get_room
```cairo
fn get_room(self: @ContractState) -> felt252
```
- **Purpose:** Returns the current room number of the Vivi character
- **Returns:** Current room number as a felt252
- **Access:** Public (read-only)

#### get_owner
```cairo
fn get_owner(self: @ContractState) -> ContractAddress
```
- **Purpose:** Returns the owner address of the Vivi character
- **Returns:** Owner's contract address
- **Access:** Public (read-only)

#### next_room
```cairo
fn next_room(ref self: ContractState, damage: felt252, heal: felt252)
```
- **Purpose:** Advances the character to the next room with damage and healing effects
- **Parameters:**
  - `damage`: Amount of damage to apply (subtracted from health)
  - `heal`: Amount of healing to apply (added to health)
- **Access:** Owner only
- **Effects:**
  - Increments room number by 1
  - Applies damage (subtracts from health)
  - Applies healing (adds to health)
- **Security:** Only the owner can call this function

## ViviFactory Contract

### Interface

```cairo
#[starknet::interface]
pub trait IViviFactory<TContractState> {
    fn create_vivi(ref self: TContractState, owner: ContractAddress) -> ContractAddress;
    fn get_vivi(self: @TContractState, owner: ContractAddress) -> ContractAddress;
}
```

### Storage

The ViviFactory contract stores the following state variables:

- `owner_to_vivi: Map<ContractAddress, Option<ContractAddress>>` - Mapping from owner addresses to their Vivi contract addresses
- `vivi_class_hash: ClassHash` - The class hash of the Vivi contract for deployment

### Functions

#### Constructor
```cairo
fn constructor(ref self: ContractState, vivi_class_hash: ClassHash)
```
- **Purpose:** Initializes the ViviFactory with the Vivi contract class hash
- **Parameters:**
  - `vivi_class_hash`: The class hash of the Vivi contract to deploy

#### create_vivi
```cairo
fn create_vivi(ref self: ContractState, owner: ContractAddress) -> ContractAddress
```
- **Purpose:** Creates a new Vivi character for the specified owner
- **Parameters:**
  - `owner`: The address that will own the new Vivi character
- **Returns:** The deployed Vivi contract address
- **Behavior:**
  - If the owner already has a Vivi, returns the existing address
  - If not, deploys a new Vivi contract and stores the mapping
- **Access:** Public

#### get_vivi
```cairo
fn get_vivi(self: @ContractState, owner: ContractAddress) -> ContractAddress
```
- **Purpose:** Retrieves the Vivi contract address for a given owner
- **Parameters:**
  - `owner`: The address to look up
- **Returns:** The Vivi contract address, or zero address if not found
- **Access:** Public (read-only)

## Usage Examples

### Creating a Vivi Character

1. **Deploy ViviFactory** with the Vivi class hash:
```cairo
// Deploy factory with Vivi class hash
let factory = deploy_contract('ViviFactory', array![vivi_class_hash]);
```

2. **Create a Vivi character** for a user:
```cairo
// Create Vivi for user
let vivi_address = factory.create_vivi(user_address);
```

3. **Interact with the Vivi character**:
```cairo
// Get character stats
let health = vivi.get_health_points();
let room = vivi.get_room();
let owner = vivi.get_owner();

// Progress to next room (owner only)
vivi.next_room(2, 1); // Take 2 damage, heal 1
```

### Game Flow

1. User calls `create_vivi` on the factory to get their character
2. User can check their character's stats using the getter functions
3. User can progress through rooms using `next_room` (owner only)
4. Each room transition applies damage and healing effects

## Development

### Building the Contracts

```bash
# Build Vivi contract
cd viving
scarb build

# Build ViviFactory contract
cd ../vivifactory
scarb build
```

### Running Tests

```bash
# Test Vivi contract
cd viving
scarb test

# Test ViviFactory contract
cd ../vivifactory
scarb test
```

### Dependencies

Both contracts use:
- **starknet**: `2.11.4` - Core Starknet functionality
- **snforge_std**: `0.43.1` - Testing framework
- **assert_macros**: `2.11.4` - Assertion macros for testing

## Security Considerations

1. **Access Control**: Only the owner can call `next_room` on their Vivi character
2. **Factory Pattern**: The factory ensures one Vivi per owner and manages deployments
3. **State Management**: Health and room progression are managed securely within the contract

## Game Mechanics

- **Health System**: Characters start with 10 health points
- **Room Progression**: Characters start in room 0 and progress through rooms
- **Damage/Healing**: Each room transition can apply both damage and healing effects
- **Ownership**: Each character has a unique owner who controls progression

## Class Hashes

- **Vivi Class Hash**: `0x0291c08d83c574f909ef911e96ee48bc4c461f7df63e300aa53a7ac61f6920c5`
- **Factory Class Hash**: `0x03ee2cada41d768a803dcfd24fe830559606133f7fcb9b94c951bcc28542ea33`