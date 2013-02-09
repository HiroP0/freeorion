# installation of scipy probably necessary to get pylab
#
#This script easiest to use if you copy it to the directory your log files are saved to, and then execute it as
# OS_Prompt>   python charts.py
#
# alternatively you can edit the DataDir variable below to point to your log files folder, and that should work also
# I do plan to further improve this to test for OS and automatically look in the corresponding default location
from pylab import *
import os
import sys
from glob import glob
import traceback
#import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

dataDir = "."
graphDir=dataDir

fileRoot="game1"
saveFile=True
turnsP=None
turnsAI=None
rankings=[]


def show_only_some(x, pos):
  val=int(x)
  if val in [3, 5, 30, 50, 80, 300, 500, 800, 3000, 5000, 8000]:
    return str(val)
  else:
    return ''


for plotType in ["PP", "RP"]:

    if plotType=="PP":
        caption="Production"
    else:
        caption="Research"

    figure(figsize=(10, 6))
    ax=gca()
    allData={}
    species={}
    empires=[]
    empireColors={}
    playerName=""
    ymin = 9999
    ymax = 0

    if not os.path.exists(dataDir+os.sep+"freeorion.log"):
        print "can't find freeorion.log"
    else:
        with open(dataDir+os.sep+"freeorion.log", 'r') as lf:
            dat1=lf.read()
            playerName="Player"
            colorParts= dat1.split("EmpireColors:")
            if len( colorParts )>=2:
              colorLine=colorParts[1].split('\n')[0].strip()
              colors=colorLine.split()
              print "Player colors = %s , type = %s"%( colors, type(colors[0]))
              if len(colors)==4:
                if type(colors[0])==type("0"):
                  empireColors[playerName]= tuple(map(lambda x: float(x)/255.0, colors))
                else:
                  empireColors[playerName]= tuple(map(lambda x: float(ord(x[0]))/255.0, colors))
            datalines = [lines.split('\n')[0] for lines in dat1.split("Current Output (turn")][1:]
            turnPP = [ ( int( parts[0] ), float( parts[1].split('/')[-1]) ) for parts in [line.split(')') for line in datalines]]
            turnsP = [ int( parts[0]) for parts in [line.split(')') for line in datalines]]
            PP = [ float( parts[1].split('/')[-1])  for parts in [line.split(')') for line in datalines]]
            RP = [ float( parts[1].split('/')[-2].split('(')[-1])  for parts in [line.split(')') for line in datalines]]
            if plotType=="PP":
                data=PP
            else:
                data=RP
            if data != []:
                ymin = min(ymin, min(data))
                ymax = max(ymax, max(data))
                #plot(turnsP[:50],data[:50], 'bo-',  label=playerName,  linewidth=2.0)
                allData[playerName]=data

    logfiles=sorted(glob(dataDir+os.sep+"A*.log"))
    empire=0
    for lfile in logfiles:
        with open(lfile, 'r') as lf:
            try:
              dat1=lf.read()
              specName=dat1.split("CapitalID:")[1].split("Species:")[1].split('\n')[0].strip()
              empireName=dat1.split("EmpireID:")[1].split("Name:")[1].split("Turn:")[0].strip()
              empires.append(empireName)
              colorParts= dat1.split("EmpireColors:")
              if len( colorParts )>=2:
                colorLine=colorParts[1].split('\n')[0].strip()
                colors=colorLine.split()
                if len(colors)==4:
                  empireColors[empireName]= tuple(map(lambda x: int(x)/255.0, colors))
                  print "empire colors for %s are %s  -- %s "%(empireName, colors, empireColors[empireName])
              datalines = [lines.split('\n')[0] for lines in dat1.split("Current Output (turn")][1:]
              turnPP = [ ( int( parts[0] ), float( parts[1].split('/')[-1]) ) for parts in [line.split(')') for line in datalines]]
              turnsAI = [ int( parts[0]) for parts in [line.split(')') for line in datalines]]
              PP = [ float( parts[1].split('/')[-1])  for parts in [line.split(')') for line in datalines]]
              RP = [ float( parts[1].split('/')[-2].split('(')[-1])  for parts in [line.split(')') for line in datalines]]
              if plotType=="PP":
                  data=PP
                  rankings.append( (PP[-1], empireName) )
              else:
                  data=RP
              if data != []:
		  thisMin=min(data)
                  if thisMin>4: ymin = min(ymin, thisMin)
                  ymax = max(ymax, max(data))
              #plot(turnsAI[:50],data[:50],  label=specName,  linewidth=2.0)
              species[empireName]=specName
              allData[empireName]=data
              empire+=1
            except:
              print "error processing %s"%lfile
              print "Error: exception triggered and caught:  ",  traceback.format_exc()

    rankings.sort()
    legend(loc='upper left',prop={"size":'medium'})
    xlabel('Turn')
    ylabel(plotType+' per turn')
    title(caption+' Point progression')
    #if saveFile:
    #    savefig(graphDir+os.sep+plotType+"_"+fileRoot+"_toTurn50.png")
    #show()

    turns=turnsP or turnsAI or range(1,len(allData.values()[0])+1)
    #if len(turns) >50:
    #if (allData.get(playerName,[]) or allData.values()[0])[-1]>100:
    #  ax.set_yscale('log',basey=10)
    ax.set_yscale('log',basey=10)
      
    #ax.axis["right"].set_visible(True)
    #figure(figsize=(10, 6))
    if playerName not in allData:
        print "can't find playerData in allData"
    else:
        if playerName in empireColors:
          plot(turnsP, allData[playerName], 'o-', color=empireColors[playerName],  label=playerName,  linewidth=2.0)
        else:
          plot(turnsP, allData[playerName], 'bx-',  label=playerName,  linewidth=2.0)
    #show()
    #for i in range(len(species)):
    #    name=empires[i]
    for rank,name in rankings[::-1]:
        if name in empireColors:
          plot(range(turns[0], turns[0]+len(allData[name])), allData[name], color=empireColors[name],  label=name+" : "+species[name],  linewidth=2.0)
        else:
          plot(range(turns[0], turns[0]+len(allData[name])), allData[name], label="(%d) "%(empires.index(name)+1)+name+" : "+species[name],  linewidth=2.0)
    legend(loc='upper left', prop={"size":9},labelspacing=0.2)
    xlabel('Turn')
    ylabel(plotType+' per turn')
    title(caption+' Point progression w/ Max Aggression=Maniacal')
    x1,x2,y1,y2 = axis()
    newY2=y2
    for yi in range(1, 10):
      if 1.05*ymax < yi*y2/10:
	newY2= yi*y2/10
	break
    print "y1: %.1f ; ymin: %.1f ; newY2/100: %.1f"%(y1, ymin, newY2/100)
    y1 = max(y1, 4, ymin, newY2/100)
    #axis( (x1,min(x2,200),y1,y2))
    #ax.yaxis.set_minor_locator(ticker.AutoMinorLocator())
    axis( (x1,x2,y1,newY2))
    grid(b=True, which='major', color='0.25',linestyle='-')
    grid(b=True, which='minor', color='0.1', linestyle='--')
    ax.yaxis.set_minor_formatter(FuncFormatter(show_only_some))
    ax.yaxis.set_ticks_position('right')
    ax.yaxis.set_ticks_position('both')
    ax.tick_params(labelleft='on')#for matplotlib versions where 'both' doesn't work
    #ax.tick_params(labelright='on')
    if saveFile:
        savefig(graphDir+os.sep+plotType+"_"+fileRoot+".png")
    show()
        