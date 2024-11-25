# Gamin Platform

A decentralized gaming ecosystem that enables true ownership of in-game assets through blockchain technology.

## Overview

Gamin is a play-to-earn gaming platform that leverages blockchain technology to provide players with verifiable ownership of their in-game assets. The platform uses smart contracts written in Clarity to manage asset ownership, trading, and player statistics.

## Features

- **Asset Ownership**: Players have true ownership of their in-game assets stored on the blockchain
- **Asset Trading**: Built-in marketplace functionality for buying and selling game assets
- **Player Statistics**: On-chain tracking of player experience and levels
- **Transferable Assets**: Support for both transferable and non-transferable (soulbound) assets

## Smart Contract Functions

### Administrative Functions

- `mint-asset`: Creates new gaming assets (restricted to contract owner)

### Player Functions

- `transfer-asset`: Transfer asset ownership to another player
- `list-asset`: List an asset for sale in the marketplace
- `purchase-asset`: Buy an asset listed in the marketplace
- `update-player-stats`: Update player experience and level information

### Read-Only Functions

- `get-asset-details`: Retrieve details about a specific asset
- `get-asset-price`: Get the listing price of an asset
- `get-player-stats`: View player statistics
- `get-total-assets`: Get the total number of assets minted

## Data Structures

### Assets
```clarity
{
    asset-id: uint,
    owner: principal,
    metadata-uri: string-utf8,
    transferable: bool
}
```

### Player Stats
```clarity
{
    experience: uint,
    level: uint
}
```

## Error Codes

- `u100`: Operation restricted to contract owner
- `u101`: Requested asset not found
- `u102`: Not authorized to perform operation

## Getting Started

1. Deploy the smart contract to your Stacks blockchain node
2. Initialize game assets using the `mint-asset` function
3. Integrate the contract functions into your game client
4. Test all functionality in a development environment before mainnet deployment

## Security Considerations

- Only the contract owner can mint new assets
- Assets marked as non-transferable cannot be traded
- Asset transfers require explicit owner authorization
- Price checks are performed before asset purchases

## Future Improvements

- Implementation of batch transfers for multiple assets
- Addition of asset rental functionality
- Integration of achievement system
- Support for asset upgrading and fusion
- Implementation of governance features for community decisions

## Contributing

Contributions are welcome! Please submit pull requests with any improvements or bug fixes.
