module.exports.calcUnsoldTokensToAlloc = function(maxTokens, price, presaleETH, publicSaleETH){
  return (maxTokens - (presaleETH*price)*1.5 - publicSaleETH*price)/2; 
};

module.exports.calcPresalePrice = function(maxTokens, price, presaleETH, publicSaleETH, presaleExtra){
  var unsoldToAlloc = module.exports.calcUnsoldTokensToAlloc(maxTokens, price, presaleETH, publicSaleETH);
  //return ((presaleETH*price)*1.5 + (unsoldToAlloc*(presaleETH/(presaleETH + publicSaleETH)))) / presaleETH;
  return (presaleETH*price*(1 + (presaleExtra/100)) + publicSaleETH*price + unsoldToAlloc) / presaleETH;
};

module.exports.calcPublicSalePrice = function(maxTokens, price, presaleETH, publicSaleETH, presaleExtra){
  if (publicSaleETH===0){
    return 0;
  } else {
    	var unsoldToAlloc = module.exports.calcUnsoldTokensToAlloc(maxTokens, price, presaleETH, publicSaleETH);
    	return (publicSaleETH*price + unsoldToAlloc) / publicSaleETH;
  }
};