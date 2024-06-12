Future plans
Build ELK Stack with Logstash and automate via NodeRed to ingest all CSVs/JSONs to ELK
Build custom Dashboards in ELK to present all ingested data
Automate E01 image mounting in FTK Image and Plaso the image and add to Node-Red flow to ingest into Timesketch/ELK.

Flow:
E01 File (watched folder) > CLI command to mount to FTK Imager > CLI command to plaso the mounted E01 file "log2timeline.exe XP.plaso E:" > process plaso file in the bottom half of the Node-Red flow
Add to end of flow to send ingest processed files into ELK stack.

Links: http://sandmaxprime.co/super-timeline-using-elk-stack/
