package com.chher.crm.workbench.dao;

import com.chher.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int save(Tran tran);

    List<Tran> pageList(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    Tran detailById(String id);

    int changeStage(Tran t);

    int getTotal();

    List<Map<String, Object>> getCharts();
}
