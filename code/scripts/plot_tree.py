import pandas as pd
from scipy.cluster.hierarchy import dendrogram, linkage
import seaborn as sns
from matplotlib import pyplot as plt
import re
import argparse 
import os


parser = argparse.ArgumentParser(description="Generate Tree")
parser.add_argument('-i',metavar='Input FAastANI file',type=str,help='Enter input FastANI file')
parser.add_argument('-s',metavar='Target sample',type=str,help='Enter target sample')
parser.add_argument('-o',metavar='Output directory',type=str,help='Enter directory for output')
args = parser.parse_args()

if not os.path.exists(args.o):
    os.makedirs(args.o)

data = pd.read_csv(args.i,delim_whitespace=True,header=None)
data.columns = ['Genome1', 'Genome2', 'ANI', 'AF1', 'AF2']

pd.set_option('mode.chained_assignment', None)
for i in range(0,len(data)):
    name = data['Genome1'].loc[i]
    name = re.sub(r'^(.*/)(.*)$',r'\2',name)
    data['Genome1'].loc[i] = name
    name = data['Genome2'].loc[i]
    name = re.sub(r'^(.*/)(.*)$',r'\2',name)
    data['Genome2'].loc[i] = name
data = data.drop_duplicates(subset=['Genome1','Genome2'])
single_data = data.copy(deep=True)

dist_matrix = 100 - data.pivot(index='Genome1', columns='Genome2', values='ANI').fillna(100)

Z = linkage(dist_matrix, method='average')

pivot = data.pivot(index='Genome1', columns='Genome2', values='ANI')

fig1 = plt.figure(figsize=(20,20))

fig1.tight_layout()


dendro = dendrogram(Z, labels=dist_matrix.index, orientation='left')



ax = fig1.gca()
labels = ax.get_yticklabels()
for label in labels:
    label.set_fontsize(16)
    if label.get_text() == args.s:
        label.set_weight('bold')
        label.set_color('blue')
        x, y = label.get_position()
        ax.plot(x - 0.99 , y, 'ro', markersize=15)
ax.set_title('Phylogeny Tree',fontsize=26,fontweight='bold', y =1.05)
fig1.savefig(str(args.o)+'/tree.png')

ordered_pivot = pivot.iloc[dendro['leaves'], dendro['leaves']]


fig2 = plt.figure(figsize=(20,20))
fig2.tight_layout()
sns.heatmap(ordered_pivot)

ax = fig2.gca()
labels = ax.get_yticklabels()
for label in labels:
    label.set_fontsize(16)
    if label.get_text() == args.s:
        label.set_weight('bold')
        label.set_color('blue')

labels = ax.get_xticklabels()
for label in labels:
    label.set_fontsize(16)
    if label.get_text() == args.s:
        label.set_weight('bold')
        label.set_color('blue')
ax.set_ylabel('Genome',fontweight='bold',fontsize=20)
ax.set_xlabel('Genome',fontweight='bold',fontsize=20)
ax.set_title('Heatmap',fontsize=26,fontweight='bold',y=1.02)
fig2.savefig(str(args.o)+'/matrix_heatmap.png')

single_data = single_data[(single_data['Genome1'] == args.s) | (single_data['Genome2'] == args.s)]
single_data = single_data.reset_index(drop=True)

fig3, ax = plt.subplots(figsize=(15, 3))
fig3.tight_layout()

row1_data = single_data[(single_data['Genome1'] == args.s)].reset_index(drop=True).sort_values(by='ANI',ascending=False)
row2_data = single_data[(single_data['Genome2'] == args.s)].reset_index(drop=True).rename(columns={'ANI':'ANI-rev', 'Genome1':'Genome2','Genome2':'Genome1'})
sorted_data = pd.merge(row1_data,row2_data,on='Genome2').drop(columns=['Genome1_x','Genome1_y','AF1_x','AF1_y','AF2_x','AF2_y']).rename(columns={'Genome2':'Genome'}).set_index('Genome').T



sns.heatmap(sorted_data, ax=ax)
ax.set_aspect(2)
xlabels = [label.get_text() for label in ax.get_xticklabels()]
ax.set_xticklabels(xlabels, rotation=45, ha='right')

fig3.subplots_adjust(bottom=0.4,left=0.07)
ax = fig3.gca()
labels = ax.get_xticklabels()
for label in labels:
    label.set_fontsize(10)
    if label.get_text() == args.s:
        label.set_weight('bold')
        label.set_color('blue')

labels = ax.get_yticklabels()
for label in labels:
    label.set_fontsize(10)
ax.set_xlabel('Genome',fontweight='bold',fontsize=16)
ax.set_title('Sample Heatmap',fontsize=18,fontweight='bold',y=1.1)
fig3.savefig(str(args.o)+'/sample_heatmap.png')