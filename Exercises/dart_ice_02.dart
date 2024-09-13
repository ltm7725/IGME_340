void main() {
    var myList1 = [0,0,0,0,0];
    myList1[1] = 1;
    print (myList1);
  
    String one = "test";
    num two = 1;
    double three = 10;
    bool four = false;
    List myList2 = [one, two, three, four];
    print (myList2);
    myList2.insert(1, "IGME");
    print (myList2);
    
    List myList3 = ['item1', 'item2', 'item3'];
    myList2.addAll(myList3);
    print (myList2);
  
    List myList4 = [123.4, 'item 6', false];
    myList2.insertAll(0, myList4);
    // myList2.insert(0, myList4); is also possible, but not 100% sure which you're referring to
    print (myList2);
  
    List myList5 = ["one", "two", "three", "four", "five", "six"];
    print (myList5);
    myList5.removeAt(2);
    print (myList5);
    myList5.removeLast();
    print (myList5);
    
    myList2.removeRange(1, 5);
    print (myList2);
}