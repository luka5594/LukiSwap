update-abis:
	forge inspect LukiswapV3Factory abi > ui/src/abi/Factory.json
	forge inspect LukiswapV3Manager abi > ui/src/abi/Manager.json
	forge inspect LukiswapV3pool abi > ui/src/abi/Pool.json
	forge inspect LukiswapV3Quoter abi > ui/src/abi/Quoter.json