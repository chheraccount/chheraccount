package com.chher.crm.workbench.dao;

import com.chher.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    int getTotalByClueIds(String[] ids);

    int deleteByClueIds(String[] ids);

    List<ClueRemark> getByClueId(String clueId);

    int deleteByClueId(String clueId);
}
