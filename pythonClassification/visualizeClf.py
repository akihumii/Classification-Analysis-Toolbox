import numpy as np
import matplotlib.pyplot as plt
import pickle
import os

target_dir = 'C:\\Users\\lsitsai\\Desktop\\Marshal\\20190131_Chronic_NHP_wireless_implant_Alvin\\Info\\classificationTmp'
# target_dir = 'C:\\Users\\lsitsai\\Desktop\\Marshal\\20190131_Chronic_NHP_wireless_implant_Alvin\\Info\\classificationTmp\\storage\\normalized'

file_feature = [f for f in os.listdir(target_dir) if f.startswith('featuresCh')]

file_class = [f for f in os.listdir(target_dir) if f.startswith('classCh')]

file_norms = [f for f in os.listdir(target_dir) if f.startswith('normsCh')]

file_clf = [f for f in os.listdir(target_dir) if f.startswith('classifierCh')]

for i in range(len(file_feature)):
    # load classifier
    clf = pickle.load(open(os.path.join(target_dir, file_clf[i]), 'rb'))

    # load features
    features = np.genfromtxt(os.path.join(target_dir, file_feature[i]), delimiter=',', defaultfmt='%f')

    # load classes
    classes = np.genfromtxt(os.path.join(target_dir, file_class[i]), delimiter=',', defaultfmt='%f')

    # load norms
    norms = np.genfromtxt(os.path.join(target_dir, file_norms[i]), delimiter=',')
    # norms = pickle.load(open(os.path.join(target_dir, file_norms[i]), 'rb'))

    # normalize the features
    # features_normalized = features
    features_normalized = features / norms
    # features_normalized = norms.transform(features)

    plt.figure(i)
    plt.clf()

    plt.scatter(clf.support_vectors_[:, 0], clf.support_vectors_[:, 1], s=80,
                facecolors='none', zorder=10, edgecolors='k')
    plt.scatter(features_normalized[:, 0], features_normalized[:, 1], c=classes, zorder=10, cmap=plt.cm.Paired,
                edgecolors='k')

    plt.axis('tight')
    x_min = min(features_normalized[:, 0])
    x_max = max(features_normalized[:, 0])
    y_min = min(features_normalized[:, 1])
    y_max = max(features_normalized[:, 1])

    XX, YY = np.mgrid[x_min:x_max:200j, y_min:y_max:200j]
    Z = clf.decision_function(np.c_[XX.ravel(), YY.ravel()])

    # Put the result into a color plot
    Z = Z.reshape(XX.shape)
    plt.pcolormesh(XX, YY, Z > 0, cmap=plt.cm.Paired)
    plt.contour(XX, YY, Z, colors=['k', 'k', 'k'], linestyles=['--', '-', '--'],
                levels=[-.5, 0, .5])

    plt.xlim(x_min, x_max)
    plt.ylim(y_min, y_max)

    # axes labels
    label_x = 'meanValue'
    label_y = 'numSignChanges'
    label_title = file_class[i]

    plt.xlabel(label_x)
    plt.ylabel(label_y)
    plt.title(label_title)

plt.show()


