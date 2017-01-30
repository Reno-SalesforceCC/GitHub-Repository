Public Class Dyna_DisplayRecords {
    //Constructor
    Public Dyna_DisplayRecords() {        
    }
    
    Public String dynaListing(List<List<String>> records, List<String> labels, Integer numberOfCols) {
        Integer totRecordsCount = records.size();
        //numberOfCols = 10;
        Integer colWidth = 0; Integer tableColWidth = 0;
        
        //Presetting numberOfCols value
        if (records.size() >= 1) {
            if (records[0].size() > 3) {
                numberOfCols = 1;
            }
            if (records[0].size() == 3 && numberOfCols > 3) {
                numberOfCols = 3;
            }
            if (records[0].size() == 2 && numberOfCols > 4) {
                numberOfCols = 4;
            }
        }
        if (totRecordsCount > 0 )  {
            colWidth = (100/numberOfCols) - 1;
            tableColWidth = (100/records[0].size()) - 2;        
        }
        String listHtml = '<div class="dyna-list-details">';
        
        for (Integer i = 0; i < totRecordsCount; i++) {
            //Populating Label row
            
            //Populating Values rows
            listHtml = listHtml + '<div class="eachBlock" style="width:'+colWidth+'%;float:left;padding:3px;text-align:left;">';
                if (labels != null && labels.size() > 0 && i < numberOfCols) {
//                listHtml = listHtml + '<div class="eachBlock" style="width:'+colWidth+'%;float:left;padding:3px;text-align:left;">';
                    listHtml = listHtml + '<div class="trow" style="width:100%;">';
                    if (labels.size() == records[0].size()) {
                        for (Integer l = 0; l < labels.size(); l++) {
                            listHtml = listHtml + '<div class="col" style="width:'+tableColWidth+'%;padding:1px;float:left;"><b>'+labels[l]+'</b></div>';
                        }
                    }
//                    listHtml = listHtml + '</div>';
                    listHtml = listHtml + '</div>';
                }

                listHtml = listHtml + '<div class="trow" style="width:100%;">';
                if (records.size() == 1 && records[i].size() == 1) {
                    String singleVal = records[i][0];
                    return singleVal;
                }
                if (records[i].size() > 0) {
                    for(Integer j = 0; j < records[i].size(); j++) {
                        listHtml = listHtml + '<div class="col" style="width:'+tableColWidth+'%;padding:1px;float:left;">'+records[i][j]+'</div>';
                    }
                }
                listHtml = listHtml + '</div>';
            listHtml = listHtml + '</div>';
        }
        listHtml = listHtml + '</div>';
        return listHtml;
    }
}