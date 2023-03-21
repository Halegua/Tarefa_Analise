import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
df = pd.read_csv("E:/Total_Covid.csv")
df = df.loc[df['estimated_population'] > 200000]
df["mortalidade"]= df['deaths']*100/df["confirmed"]

l = []
a = 0
b = 0
c = 0
d=0
for _,r in df.iterrows():
    if r['pib_capita'] <= df.pib_capita.quantile(.25):
        l.append("d")
    elif r['pib_capita'] <= df.pib_capita.quantile(.5):
        l.append("c")
    elif r['pib_capita'] <= df.pib_capita.quantile(.75):
        l.append("b")
    else:
        l.append("a")

df["classe_capita"] = l


#sns.scatterplot(data=df, x="mortalidade", y="AVG_IDADE")

groups = df.groupby('classe_capita')
for name, group in groups:
    plt.plot(group.mortalidade, group.AVG_IDADE, marker='o', linestyle='', label=name)   
plt.legend()
plt.legend()

plt.show()
