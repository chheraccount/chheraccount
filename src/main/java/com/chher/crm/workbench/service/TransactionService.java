package com.chher.crm.workbench.service;

import com.chher.crm.workbench.domain.Tran;
import com.chher.crm.workbench.domain.TranHistory;
import com.chher.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface TransactionService {
    List<String> getNameList(String name);

    boolean save(Tran tran, String company);

    PaginationVO<Tran> pageList(Map<String, Object> map);

    Tran getTran(String id);

    Map<String, Object> getCharts();

    boolean changeStage(Tran t);

    List<TranHistory> getHistoryListByTranId(String tranId);
}
