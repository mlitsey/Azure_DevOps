param itemCount int = 5

var stringArray = [for i in range(1, itemCount): 'item${(i + 1)}']

output arrayResult array = stringArray
