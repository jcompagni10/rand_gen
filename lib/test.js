function letterCombinations(str) {
  const numToLet = {1:[], 2: ['a','b','c'], 3: ['d', 'e', 'f'], 4: ['g', 'h', 'i'], 5: ['j','k','l'], 6: ['m', 'n', 'o'], 7: ['p', 'q', 'r', 's'], 8: ['t', 'u', 'v'], 9: ['w', 'x', 'y', 'z']};
  const len = str.length;
  let  output = [''];
  for (let i = 0; i < len; i++){
    let letters = numToLet[str[i]];
    let newOutput = [];
    output.forEach(segment => {
      letters.forEach(letter => ( newOutput.push(segment + letter)));
    });
    output = newOutput;
  }
  return output;
}