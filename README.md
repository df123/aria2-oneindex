## aria2-oneindex
aria2下载完成后，使用oneindex自动上传到onedirve

## 安装
使用git克隆到本地  
```git clone https://github.com/df123/aria2-oneindex.git```  
切换到目录  
```cd aria2-oneindex```  
给予执行权限  
```chmod +x aria2.sh```  
执行  
```./aria2.sh```  

## 用户
在脚本安装时，自动创建aria2用户，此用户使用/bin/false作为bash  
家目录位于  
```/home/aria2```  

## aria2
aria2由aria2用户运行  
aria2的相关文件位于  
```/home/aria2/.aria2```  
下载默认在  
```/home/aria2/downloads```  

aria2默认rpc端口为```6800```  
可以执行```cat /home/aria2/.aria2/aria2.conf | grep rpc-listen-port```查看

启动aria2  
```systemctl start aria2.serice```  
关闭aria2  
```systemctl stop aria2.serice```  
重启aria2  
```systemctl restart aria2.serice```  

## aria2脚本触发说明
未下载完成，按删除任务，触发删除脚本；  
未下载完成，按暂停任务，不触发脚本；  
  
下载完成，做种未完成，按删除任务，触发移动脚本;  
下载完成，做种未完成，按暂停任务，不触发脚本；  

## aria2脚本执行日志
上传脚本日志  
```/home/aria2/.aria2/upload.log```  
删除脚本日志  
```/home/aria2/.aria2/delete.log```  

## oneindex
默认安装的web服务器为apache2，如果已经安装nginx，则使用nginx，不安装apache2   
默认端口为```8080```   
apache2可以执行```cat /etc/apache2/sites-enabled/oneindex.conf | grep '^<VirtualHost'```查看
oneindex具体使用，请参考[oneindex](https://github.com/donwa/oneindex)  

## 参考引用
仅aria2.sh中的部分代码有参考和引用https://github.com/fangwater/OneDrive-vps-builder  
具体引用部分将在代码中标出。

