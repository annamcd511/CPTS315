import numpy as np
import random


def sign(value):
    if value > 0:
        return 1
    if value <= 0:
        return -1

def shuffle(list1, list2):
    # Shuffle two lists with same order
    # Using zip() + * operator + shuffle()
    random.seed(0)
    temp = list(zip(list1, list2))
    random.shuffle(temp)
    res1, res2 = zip(*temp)
    # res1 and res2 come out as tuples, and so must be converted to lists.
    res1, res2 = list(res1), list(res2)
    return res1, res2

train = []

with open('ML_T.csv', 'r') as f:
    for line in f:
        temp = []
        item = line.split(",")
        for i in item:
            temp.append(int(i))
        train.append(temp)
    
y = []   
with open("labels.txt", "r") as f:
    for line in f:
        y.append(int(line))


w = [0]*15
correct = [0]*21
incorrect = [0]*21
train, y = shuffle(train, y)

def train_classifier(w, iteration):
    for i in range(0, 384):
        y_hat = sign(np.dot(w, train[i]))
        if y_hat == y[i]:
            correct[iteration] += 1
        else:
            incorrect[iteration] += 1
            update = [y[i]*value for value in train[i]]
            #update = [0.1*value for value in update]
            w = [sum(tup) for tup in zip(w, update)]

    return w

def test_classifier(w):
    test_correct = 0
    test_incorrect = 0
    for i in range(385, 484):
        y_hat = sign(np.dot(w, train[i]))
        if y_hat == y[i]:
            test_correct += 1
        else:
            test_incorrect += 1
    return test_incorrect, test_correct
    
for iteration in range(0,21):
    w = train_classifier(w, iteration)
    print("iteration: ", iteration)
    print("number of training mistakes: ", incorrect[iteration])
    print("training accuracy: ", correct[iteration]/384)
    print("-------------------------------------")
    if iteration == 20:
        test_incorrect, test_correct = test_classifier(w)
        print("number of testing mistakes: ", test_incorrect)
        print("testing accuracy: ", test_correct/100)