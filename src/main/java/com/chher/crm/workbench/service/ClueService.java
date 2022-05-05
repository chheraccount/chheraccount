package com.chher.crm.workbench.service;

import com.chher.crm.vo.PaginationVO;
import com.chher.crm.workbench.domain.Activity;
import com.chher.crm.workbench.domain.Clue;
import com.chher.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface ClueService {
    boolean saveClue(Clue c);

    PaginationVO<Clue> pageList(Map<String, Object> map);

    boolean deleteClue(String[] ids);

    Map<String, Object> getUserListAndClue(String id);

    boolean updateClue(Clue c);

    Clue getClue(String id);

    List<Activity> getActivityByClueId(String clueId);

    boolean unbund(String id);

    List<Activity> getNotBundActivityByName(String name, String clueId);

    boolean bund(String clueId, String[] ids);

    List<Activity> getActivityByName(String name);

    boolean convert(String clueId, Tran tran, String createBy);
}
