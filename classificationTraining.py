import numpy as np
import pickle
from sklearn.svm import SVC
import os
import sys


def train(target_file):
    print("started...")
    cwd = os.getcwd()
    target_dir = os.path.join(cwd, 'classificationTmp')

    print(target_file)

    if os.path.exists(target_dir):
        data_features_all = [np.genfromtxt(os.path.join(target_dir, f), delimiter=',')
                             for f in os.listdir(target_dir) 
                             if f.startswith('featuresTmp') and target_file in f]

        data_class_all = [np.genfromtxt(os.path.join(target_dir, f), delimiter=',')
                          for f in os.listdir(target_dir) 
                          if f.startswith('classTmp') and target_file in f]

        clf = SVC(kernel='poly', degree=3, gamma='auto')

        for i, x in enumerate(data_features_all):
            classifiers = clf.fit(x.astype(np.float), data_class_all[i].astype(np.float))
            filename = 'classifierTmp%d.sav' % i
            pickle.dump(classifiers, open(os.path.join(target_dir, filename), 'wb'))
            print("%s%d has been saved..." % (os.path.join(target_dir, filename), i))

    else:
        print("no %s is found..." % target_dir)

    print("done...")


if __name__ == "__main__":
    train(str(sys.argv[1]))
