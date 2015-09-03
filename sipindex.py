# Language:	Sip Index
# Maintainer:	Emrah Soytekin (emrahsoytekin@gmail.com)
# URL:		
# Last Change: 03.09.2015_08.56
import vim
import string
import re

bufferSize = len(vim.current.buffer)
SEND       = 'send'
RECEIVE    = 'recv'
PAUSE      = 'pause'
ACTION     = 'action'
temp_list  = []
def printValues(action,arrowString,messageType,lineNumber):
    """adds values to vim buffer array"""
    temp_list.append("{type} {arrow} {message} : {line}".format(type=action, arrow=arrowString,message=messageType,line=lineNumber))
    return
commentEnd=-1
sendEnd=-1
actionEnd=-1
for i in range(0,bufferSize):
    if i<=max(commentEnd,sendEnd,actionEnd):
        #print "{}-{},{},{}".format(i,commentEnd,sendEnd,actionEnd)
        continue
    currentLine = vim.current.buffer[i]
    searchComment=re.match(r"^\s*<!--.*$",currentLine,re.I|re.M)
    if searchComment:
        for j in range(i,999):
            currentLine=vim.current.buffer[j]
            searchCommentEnd=re.match(r"^.*-->\s*$",currentLine,re.I|re.M)
            if searchCommentEnd: 
                commentEnd=j
                break

    searchType=re.match(r"^\s*<(\w+).*$",currentLine,re.I|re.M)
    if  searchType:
        action = searchType.group(1)
        arrowString="---"
        messageType=""
        lineNumber=""

        if action==SEND:
            arrowString = "-->"
            lineNumber = i+1
            for j in range(i,999):
                currentLine = vim.current.buffer[j] 
                searchEndOfMessageMultiLine = re.match(r"^\s*<\/\w+>\s*$",currentLine,re.I|re.M)
                searchEndOfMessageOneLine = re.match(r"^\s*<.*\/>\s*$",currentLine,re.I|re.M)
                if searchEndOfMessageMultiLine or searchEndOfMessageOneLine:
                   sendEnd=j
                   break
                if messageType=="":
                    searchMessageTypeServer=re.match(r"^\s*SIP/2\.0\s*(\w+(\s+\w+)*)\s*$",currentLine,re.I|re.M)
                    searchMessageTypeClient = re.match(r"^\s*(\w+)\s+sip:.*SIP\/2\.0$",currentLine,re.I | re.M)
                    if searchMessageTypeServer:    
                        messageType = searchMessageTypeServer.group(1)
                    elif searchMessageTypeClient:
                        messageType = searchMessageTypeClient.group(1)
                #elif messageType == "200 OK":
                else:
                    searchSDP=re.match(r"\s*o=.*$",currentLine,re.I|re.M)
                    if searchSDP:
                        messageType=messageType+" (SDP)"
                        sendEnd=j
                        break
            printValues(action,arrowString,messageType,lineNumber)
        elif action == RECEIVE:
            arrowString="<--"
            lineNumber = i+1
            searchMessageType=re.match(r"^\s*<recv\s+request=\"(\w+)\".*$",currentLine,re.I|re.M)
            searchMessageTypeClient = re.match(r"^\s*<recv\s+response=\"(\w+)\".*$",currentLine,re.I | re.M)
            if searchMessageType:
                messageType=searchMessageType.group(1)
            elif searchMessageTypeClient:
                messageType = searchMessageTypeClient.group(1)
            printValues(action,arrowString,messageType,lineNumber)
        elif action == PAUSE:
            lineNumber = i+1
            searchMessageType=re.match(r"^\s*<pause\s*milliseconds=\"(\d+)\".*$",currentLine,re.I|re.M)
            if searchMessageType:
                messageType=searchMessageType.group(1)
            printValues(action,arrowString,messageType,lineNumber)
        elif action == ACTION:
            for j in range(i,999):
                currentLine=vim.current.buffer[j]
                searchMessageType=re.match(r"^\s*<exec\s*(\w+=\".*\").*$",currentLine,re.I|re.M)
                if searchMessageType:
                    actionEnd=j
                    lineNumber=j+1
                    messageType=searchMessageType.group(1)
                    break
            printValues(action,arrowString,messageType,lineNumber)


vim.command('let g:arraySipIndex = {lst}'.format(lst=temp_list));
