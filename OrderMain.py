#Order class that has each orders id, price, and number of shares
class Order:
    def __init__(self, orderId, price, size):
        self.orderId = orderId
        self.price = price
        self.size = size


    def reduce_order(self, reduceAmount):
        self.size -= reduceAmount
        if self.size <= 0:
            del self

#method that calculates the profit
def handle_sell(orderList, shares):
    profit = 0
    largestPrice = 0
    largestIndex = 0

    for x in range(len(orderList)):
        if orderList[x].price > largestPrice:
            largestPrice = orderList[x].price
            largestIndex = x

    if orderList[largestIndex].size >= shares:
        return shares * largestPrice
    elif orderList[largestIndex].size < shares:
        profit = orderList[largestIndex].size * orderList[largestIndex].price
        newShares = shares - orderList[largestIndex].size
        orderList.remove(orderList[largestIndex])
        return profit + handle_sell(orderList, newShares)



def main():
    #opens log file
    f = open("book_analyzer.in")
    #creates a list that will hold each order
    orderList = []
    #The amount of shares in the market
    totalShares = 0
    #profit from selling shares
    profit = 0.0

    #reads each line in the file
    for line in f:
        #checks for a "Add order message"
        if line.__contains__("A"):
            #Checks for a sell message
            if line.__contains__("S"):
                #takes the line in the function and puts each string
                #into an array
                l = line.split(" ")
                #creates and adds an order to the list
                orderList.append(Order(l[2], float(l[4]), int(l[5])))
                #
                totalShares += int(l[5])
                if totalShares >= 200:
                    #calls the method that will determine profit from selling shares
                    if handle_sell(orderList.copy(), 200) > profit:
                        profit = handle_sell(orderList.copy(), 200)
                        print("S " + str(profit))
                    else:
                        print("S N/A")
            #Chekcs for a buy message
            elif line.__contains__("B"):
                # takes the line in the function and puts each string
                # into an array
                l = line.split(" ")
                # creates and adds an order to the list
                orderList.append(Order(l[2], float(l[4]), int(l[5])))
                #adds the number of shares to the totalShares in the market
                totalShares += int(l[5])

                if totalShares >= 200:
                    # calls the method that will determine profit from selling shares
                    if handle_sell(orderList.copy(), 200) > profit:
                        profit = handle_sell(orderList.copy(), 200)
                        print("S " + str(profit))
                    else:
                        print("S N/A")
        #Checks for a reduce order message
        elif line.__contains__("R"):
            l = line.split(" ")
            for x in orderList:
                if x.orderId == l[2]:
                    totalShares -= int(l[3])
                    x.reduce_order(int(l[3]))
                    if x.size <= 0:
                        orderList.remove(x)
                        x.reduce_order(int(l[3]))
    #closes the file
    f.close()

#runs the program
main()


