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
        file_feature = [f for f in os.listdir(target_dir)
                        if f.startswith('featuresCh') and target_file in f]

        file_class = [f for f in os.listdir(target_dir)
                      if f.startswith('classCh') and target_file in f]

        clf = SVC(kernel='poly', degree=3, gamma='auto')

        for i in range(len(file_class)):
            features_tmp = np.genfromtxt(os.path.join(target_dir, file_feature[i]), delimiter=',')
            
            class_tmp = np.genfromtxt(os.path.join(target_dir, file_class[i]), delimiter=',')

            classifiers = clf.fit(features_tmp.astype(np.float), class_tmp.astype(np.float))
            
            filename = 'classifierCh%s.sav' % file_feature[i][file_feature[i].find('Ch')+2]

            pickle.dump(classifiers, open(os.path.join(target_dir, filename), 'wb'))
            print("%s%d has been saved..." % (os.path.join(target_dir, filename), i))

    else:
        print("no %s is found..." % target_dir)

    print("done...")


if __name__ == "__main__":
    train(str(sys.argv[1]))
