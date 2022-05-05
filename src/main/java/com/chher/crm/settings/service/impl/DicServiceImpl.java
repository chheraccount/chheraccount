package com.chher.crm.settings.service.impl;

import com.chher.crm.settings.dao.DicTypeDao;
import com.chher.crm.settings.dao.DicValueDao;
import com.chher.crm.settings.domain.DicType;
import com.chher.crm.settings.domain.DicValue;
import com.chher.crm.settings.service.DicService;
import com.chher.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImpl implements DicService {
    private DicTypeDao dicTypeDao = SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dicValueDao = SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);


    public Map<String, List<DicValue>> getAll() {

        Map<String, List<DicValue>> map = new HashMap<String, List<DicValue>>();
        //查询需要取出的类型
        List<DicType> dicTypes = dicTypeDao.getAll();
        for(DicType dicType:dicTypes){

            String codeType = dicType.getCode();

            map.put(dicType.getCode()+"List",dicValueDao.getByTypeCode(codeType));

        }


        //查询类型对应的值

        return map;
    }
}
