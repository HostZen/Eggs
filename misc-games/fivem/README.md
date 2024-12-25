# FiveM - GTA:V Modification

FiveM is a modification framework for Grand Theft Auto V, allowing you to play on customized multiplayer servers. This README provides information on setting up and configuring your FiveM server.

## Default Ports

- **Game Port:** 30120 (TCP and UDP)
- **TXADMIN Port:** 40120 (TCP only)

## Docker Image

We use the `ghcr.io/parkervcp/yolks:debian` image for both the installer and the runtime container.

## Configuration

The following environment variables can be configured:

- `PORT_TXADMIN`: Port for TXADMIN (default: 40120)
- `ENABLE_TXADMIN`: Enable TXADMIN (default: true)
- `FIVEM_LICENSE`: Your FiveM license key
- `MAX_PLAYERS`: Maximum number of players allowed on the server

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Contact

For any questions or support, please open an issue on the GitHub repository.
