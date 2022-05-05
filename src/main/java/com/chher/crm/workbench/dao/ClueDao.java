package com.chher.crm.workbench.dao;

import com.chher.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

    public interface ClueDao {

    int save(Clue c);

    List<Clue> pageList(Map<String, Object> map);

    int getTotalByCondition(Map<String, Object> map);

    int deleteByIds(String[] ids);

    Clue getById(String id);

    int updateById(Clue c);

    Clue detailById(String id);

    int deleteById(String clueId);
}
