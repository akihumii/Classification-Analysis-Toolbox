import numpy as np
from matplotlib.axes import Axes
import matplotlib.pyplot as plt
import pickle

# load classifier
filename_clf = 'C:\\Users\\lsitsai\\Desktop\\Marshal\\20190131_Chronic_NHP_wireless_implant_Alvin\\Info\\classificationTmp\\classifierCh4.sav'
clf = pickle.load(open(filename_clf, 'rb'))

# load features
filename_feature = 'C:\\Users\\lsitsai\\Desktop\\Marshal\\20190131_Chronic_NHP_wireless_implant_Alvin\\Info\\classificationTmp\\featuresCh4_data 20190131 134012_20190219131803_20190219132220.csv'
features = np.genfromtxt(filename_feature, delimiter=',', defaultfmt='%f')

# load classes
filename_class = 'C:\\Users\\lsitsai\\Desktop\\Marshal\\20190131_Chronic_NHP_wireless_implant_Alvin\\Info\\classificationTmp\\classCh4_data 20190131 134012_20190219131803_20190219132220.csv'
classes = np.genfromtxt(filename_class, delimiter=',', defaultfmt='%f')

# # we create 40 separable points
# X, y = make_blobs(n_samples=40, centers=2, random_state=6)
#
# # fit the model, don't regularize for illustration purposes
# clf = svm.SVC(kernel='linear', C=1000)
# clf.fit(X, y)
#
plt.scatter(features[:, 0], features[:, 1], c=classes, s=30, cmap=plt.cm.Paired)

# change x limit
ax = plt.gca()

x_min = min(features[:, 0])
x_max = max(features[:, 0])

ax.set_xlim([x_min, x_max])

# plot the decision function
xlim = ax.get_xlim()
ylim = ax.get_ylim()

# create grid to evaluate model
xx = np.linspace(xlim[0], xlim[1], 30)
yy = np.linspace(ylim[0], ylim[1], 30)
YY, XX = np.meshgrid(yy, xx)
xy = np.vstack([XX.ravel(), YY.ravel()]).T
Z = clf.decision_function(xy).reshape(XX.shape)

# plot decision boundary and margins
ax.contour(XX, YY, Z, colors='k', levels=[-1, 0, 1], alpha=0.5,
           linestyles=['--', '-', '--'])
# plot support vectors
ax.scatter(clf.support_vectors_[:, 0], clf.support_vectors_[:, 1], s=100,
           linewidth=1, facecolors='none', edgecolors='k')
plt.show()